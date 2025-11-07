/*
Admin Users Dashboard
Purpose: Simple, safe controls to manage user type and account status.

Data contract (expected user_profiles schema):
- id: uuid (same as auth.users.id)
- email: text
- full_name: text (optional)
- user_type: text enum ('pet_parent','business','shelter','admin')
- status: text enum ('active','locked','removed') default 'active'
- locked_at: timestamptz (optional)
- removed_at: timestamptz (optional)
- removed_reason: text (optional)
- created_at: timestamptz (default now())

Minimum RLS policies (Supabase SQL):
-- Enable RLS on user_profiles
-- Allow admins to read/write all rows; non-admins can only read/update self when needed
-- Admin is determined by presence in admin_users table with active=true

-- Example helper:
-- create or replace function is_admin(uid uuid) returns boolean as $$
--   select exists(select 1 from admin_users a where a.active = true and a.user_id = uid)
--   or exists(select 1 from admin_users a where a.active = true and lower(a.email) = lower((select email from auth.users where id = uid)));
-- $$ language sql stable;
--
-- alter table user_profiles enable row level security;
-- create policy "admin can read" on user_profiles for select using ( is_admin(auth.uid()) );
-- create policy "admin can write" on user_profiles for update using ( is_admin(auth.uid()) );
-- create policy "user can read self" on user_profiles for select using ( id = auth.uid() );
-- create policy "user can update self minimal" on user_profiles for update using ( id = auth.uid() );

Security note: Do NOT expose serviceRole keys in production frontend. Use edge functions.
*/

(function(){
  const { createClient } = supabase;
  const client = createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);

  // Track pending changes before save
  const pendingChanges = {};
  
  // Admin auth gate: require user_type = 'admin' in user_profiles
  async function checkAdminAuth() {
    const { data: { session }, error } = await client.auth.getSession();
    if (error || !session) {
      window.location.href = 'admin-login.html';
      return false;
    }
    
    // Check if user has admin user_type in user_profiles
    const { data: profile, error: profileErr } = await client
      .from('user_profiles')
      .select('user_type, email')
      .eq('id', session.user.id)
      .maybeSingle();
    
    if (profileErr || !profile || profile.user_type !== 'admin') {
      console.error('Admin access denied:', profileErr || 'User is not an admin');
      await client.auth.signOut();
      alert('Access denied. Only users with Admin type can access this page.');
      window.location.href = 'admin-login.html';
      return false;
    }
    
    return true;
  }

  // State
  let rows = [];
  let filtered = [];
  const TYPES = ['pet_parent','business','shelter','vet','admin'];

  // Elements
  const $body = () => document.getElementById('usersContainer');
  const $search = () => document.getElementById('searchInput');
  const $refresh = () => document.getElementById('refreshBtn');

  const $stat = (id, v) => { const el = document.getElementById(id); if (el) el.textContent = v; };

  // Modal
  function openModal({ title, body, onConfirm }){
    const modal = document.getElementById('confirmModal');
    const t = document.getElementById('modalTitle');
    const b = document.getElementById('modalBody');
    const btnC = document.getElementById('modalConfirm');
    const btnX = document.getElementById('modalCancel');
    t.textContent = title;
    b.innerHTML = body;
    btnC.onclick = async () => { try { await onConfirm?.(); } finally { closeModal(); } };
    btnX.onclick = closeModal;
    modal.classList.add('show');
    document.body.style.overflow = 'hidden';
  }
  function closeModal(){
    const modal = document.getElementById('confirmModal');
    modal.classList.remove('show');
    document.body.style.overflow = '';
  }
  window.addEventListener('click', (e)=>{
    const modal = document.getElementById('confirmModal');
    if(e.target === modal) closeModal();
  });

  // Load
  async function loadProfiles(){
    const tbody = $body();
    tbody.innerHTML = '<div class="loading">Loading users…</div>';
    
    console.log('Loading user profiles...');
    
    try {
      // Get the current session
      const { data: { session }, error: sessionError } = await client.auth.getSession();
      if (sessionError || !session) {
        tbody.innerHTML = '<div class="empty">Authentication required. Please log in again.</div>';
        return;
      }

      // Call the edge function using direct fetch (more reliable than invoke)
      const response = await fetch(`${SUPABASE_CONFIG.url}/functions/v1/admin-get-users`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${session.access_token}`,
          'apikey': SUPABASE_CONFIG.anonKey
        }
      });

      if (!response.ok) {
        const errorData = await response.json();
        console.error('Error loading profiles:', errorData);
        let errorMessage = escapeHTML(errorData.error || 'Unknown error');
        let helpText = '<small>Unable to load user profiles. Please try again.</small>';
        
        if (errorData.error?.includes('Admin access required')) {
          helpText = '<small>You do not have admin privileges to view this data.</small>';
        }
        
        tbody.innerHTML = `<div class="empty">${errorMessage}<br>${helpText}</div>`;
        return;
      }

      const data = await response.json();

      if (!data || !data.profiles) {
        console.log('No user profiles found');
        tbody.innerHTML = '<div class="empty">No users found in the database.<br><small>The user_profiles table exists but is empty. Users will appear here after they register.</small></div>';
        return;
      }

      console.log('Loaded profiles data:', data.profiles);
      
      rows = (data.profiles || []).map(r => ({
        ...r,
        user_type: r.user_type || 'pet_parent',
        status: r.status || 'active',
        full_name: (r.first_name && r.last_name) ? `${r.first_name} ${r.last_name}` : (r.first_name || r.last_name || null),
        email: r.email,
        id: r.id,
        created_at: r.created_at
      }));
      console.log('Processed rows:', rows.length);
      
      filtered = rows;
      render();
    } catch (error) {
      console.error('Unexpected error:', error);
      tbody.innerHTML = '<div class="empty">An unexpected error occurred while loading users.</div>';
    }
  }

  function render(){
    const tbody = $body();
    if (!filtered.length) {
      tbody.innerHTML = '<div class="empty">No users found</div>';
    } else {
      tbody.innerHTML = filtered.map(r => rowHTML(r)).join('');
    }
    updateStats();
    bindRowEvents();
  }

  function rowHTML(r){
    const badgeClass = `status-${r.status}`;
    const options = TYPES.map(t => `<option value="${t}" ${t===r.user_type?'selected':''}>${labelType(t)}</option>`).join('');
    return `
      <div class="user-row" data-id="${r.id}">
        <div class="user-info">
          <div class="user-name">${escapeHTML(r.full_name || r.email || r.id)}</div>
          <div class="user-email">${escapeHTML(r.email || '')}</div>
          <div class="user-created">Created ${formatDate(r.created_at)}</div>
        </div>
        <div>
          <select class="user-type-select js-type" aria-label="User type">
            ${options}
          </select>
        </div>
        <div>
          <span class="status-badge ${badgeClass}">${r.status}</span>
        </div>
        <div class="action-buttons">
          ${r.status !== 'locked' ? `<button class="btn-action btn-lock js-lock">Lock</button>` : `<button class="btn-action btn-unlock js-unlock">Unlock</button>`}
          <button class="btn-action btn-remove js-remove">Remove</button>
        </div>
      </div>`;
  }

  function bindRowEvents(){
    document.querySelectorAll('#usersContainer .user-row').forEach(row => {
      const id = row.getAttribute('data-id');
      const sel = row.querySelector('.js-type');
      const lock = row.querySelector('.js-lock');
      const unlock = row.querySelector('.js-unlock');
      const remove = row.querySelector('.js-remove');
      if (sel) sel.addEventListener('change', e => onTypeChange(id, e.target.value));
      if (lock) lock.addEventListener('click', () => onLock(id));
      if (unlock) unlock.addEventListener('click', () => onUnlock(id));
      if (remove) remove.addEventListener('click', () => onRemove(id));
    });
  }

  function updateStats(){
    $stat('statTotal', rows.length);
    $stat('statActive', rows.filter(r => r.status==='active').length);
    $stat('statLocked', rows.filter(r => r.status==='locked').length);
    $stat('statRemoved', rows.filter(r => r.status==='removed').length);
  }

  // Actions
  async function onTypeChange(id, type){
    const rec = rows.find(r => r.id===id);
    if (!rec) return;
    
    console.log('onTypeChange called:', { id, type, rec });
    
    // Store pending change instead of immediate save
    if (!pendingChanges[id]) {
      pendingChanges[id] = {};
    }
    pendingChanges[id].user_type = type;
    
    console.log('Pending changes:', pendingChanges);
    
    // Mark row as modified
    const rowElement = document.querySelector(`.user-row[data-id="${id}"]`);
    if (rowElement) {
      rowElement.classList.add('modified');
      console.log('Added modified class to row');
    } else {
      console.log('Row element not found for id:', id);
    }
    
    updateSaveButton();
  }

  function onLock(id){
    const rec = rows.find(r => r.id===id);
    if(!rec) return;
    openModal({
      title: 'Lock Account',
      body: `<p>Lock ${escapeHTML(rec.email || rec.full_name || rec['first name'] || rec.id)}? They won't be able to sign in until unlocked.</p>`,
      onConfirm: async () => {
        await updateProfile(id, { status: 'locked', locked_at: new Date().toISOString() });
        rec.status = 'locked';
        render();
      }
    });
  }

  function onUnlock(id){
    const rec = rows.find(r => r.id===id);
    if(!rec) return;
    openModal({
      title: 'Unlock Account',
      body: `<p>Unlock ${escapeHTML(rec.email || rec.full_name || rec['first name'] || rec.id)}?</p>`,
      onConfirm: async () => {
        await updateProfile(id, { status: 'active', locked_at: null });
        rec.status = 'active';
        render();
      }
    });
  }

  function onRemove(id){
    const rec = rows.find(r => r.id===id);
    if(!rec) return;
    openModal({
      title: 'Remove Account',
      body: `<p>Soft-remove ${escapeHTML(rec.email || rec.full_name || rec['first name'] || rec.id)}? This sets status to "removed" and they cannot access the site.</p>`,
      onConfirm: async () => {
        await updateProfile(id, { status: 'removed', removed_at: new Date().toISOString(), removed_reason: 'Admin action' });
        rec.status = 'removed';
        render();
      }
    });
  }

  async function updateProfile(id, patch){
    try {
      // Get the current session
      const { data: { session }, error: sessionError } = await client.auth.getSession();
      if (sessionError || !session) {
        throw new Error('Authentication required');
      }

      // Call the edge function using direct fetch
      const response = await fetch(`${SUPABASE_CONFIG.url}/functions/v1/admin-update-user`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${session.access_token}`,
          'apikey': SUPABASE_CONFIG.anonKey,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          userId: id,
          updates: patch
        })
      });

      if (!response.ok) {
        const errorData = await response.json();
        console.error('Error updating profile:', errorData);
        throw new Error(errorData.error || 'Failed to update user profile');
      }

      const data = await response.json();

      if (!data || !data.success) {
        throw new Error('Update operation failed');
      }

      return data;
    } catch (err) {
      console.error('updateProfile error:', err);
      throw err;
    }
  }

  function updateSaveButton() {
    const saveBtn = document.getElementById('saveChangesBtn');
    const changeCount = document.getElementById('changeCount');
    const count = Object.keys(pendingChanges).length;
    
    console.log('updateSaveButton called:', { count, pendingChanges, saveBtn, changeCount });
    
    if (count > 0) {
      saveBtn.style.display = 'inline-block';
      changeCount.textContent = count;
      console.log('Save button shown with count:', count);
    } else {
      saveBtn.style.display = 'none';
      console.log('Save button hidden');
    }
  }

  async function saveAllChanges() {
    const saveBtn = document.getElementById('saveChangesBtn');
    const ids = Object.keys(pendingChanges);
    
    if (ids.length === 0) return;
    
    // Disable button during save
    saveBtn.disabled = true;
    saveBtn.textContent = '💾 Saving...';
    
    let successCount = 0;
    let errorCount = 0;
    const errors = [];
    
    for (const id of ids) {
      try {
        await updateProfile(id, pendingChanges[id]);
        
        // Update local record
        const rec = rows.find(r => r.id === id);
        if (rec && pendingChanges[id].user_type) {
          rec.user_type = pendingChanges[id].user_type;
        }
        if (rec && pendingChanges[id].status) {
          rec.status = pendingChanges[id].status;
        }
        
        // Remove modified class
        const rowElement = document.querySelector(`.user-row[data-id="${id}"]`);
        if (rowElement) {
          rowElement.classList.remove('modified');
        }
        
        successCount++;
      } catch (e) {
        errorCount++;
        const rec = rows.find(r => r.id === id);
        errors.push(`${rec?.email || id}: ${e.message}`);
      }
    }
    
    // Clear pending changes
    Object.keys(pendingChanges).forEach(key => delete pendingChanges[key]);
    updateSaveButton();
    
    // Re-enable button
    saveBtn.disabled = false;
    saveBtn.innerHTML = '💾 Save Changes (<span id="changeCount">0</span>)';
    
    // Show results
    if (errorCount === 0) {
      alert(`✅ Successfully saved ${successCount} change(s)`);
      render(); // Refresh display
    } else {
      alert(`⚠️ Saved ${successCount} change(s) with ${errorCount} error(s):\n\n${errors.join('\n')}`);
      render(); // Refresh display
    }
  }

  // Search
  function applySearch(){
    const q = ($search().value || '').toLowerCase().trim();
    if (!q) { filtered = rows; render(); return; }
    filtered = rows.filter(r =>
      (r.email||'').toLowerCase().includes(q) ||
      (r.full_name||'').toLowerCase().includes(q) ||
      (r['first name']||'').toLowerCase().includes(q)
    );
    render();
  }

  function labelType(t){
    switch(t){
      case 'pet_parent': return 'Pet Parent';
      case 'business': return 'Business';
      case 'shelter': return 'Shelter/Rescue';
      case 'vet': return 'Veterinarian';
      case 'admin': return 'Admin';
      default: return t;
    }
  }

  function formatDate(iso){
    try { return new Date(iso).toLocaleDateString(); } catch { return ''; }
  }

  function escapeHTML(s){
    return String(s||'').replace(/[&<>"]+/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
  }

  // Public logout for header button
  window.logout = async function(){
    await client.auth.signOut();
    window.location.href = 'admin-login.html';
  }

  // Init
  document.addEventListener('DOMContentLoaded', async () => {
    if (!(await checkAdminAuth())) return;
    $search().addEventListener('input', applySearch);
    $refresh().addEventListener('click', loadProfiles);
    
    // Add Save button event listener
    const saveBtn = document.getElementById('saveChangesBtn');
    if (saveBtn) {
      saveBtn.addEventListener('click', saveAllChanges);
    }
    
    await loadProfiles();
  });
})();
