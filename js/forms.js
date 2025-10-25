/**
 * Form Validation and Handling Utilities
 */

/**
 * Validates an email address
 * @param {string} email - Email address to validate
 * @returns {boolean} - True if valid, false otherwise
 */
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(String(email).toLowerCase());
}

/**
 * Validates a phone number (basic validation)
 * @param {string} phone - Phone number to validate
 * @returns {boolean} - True if valid, false otherwise
 */
function validatePhone(phone) {
    const re = /^[\d\s\-\+\(\)]{10,}$/;
    return re.test(phone);
}

/**
 * Validates that a field is not empty
 * @param {string} value - Value to validate
 * @returns {boolean} - True if not empty, false otherwise
 */
function validateRequired(value) {
    return value.trim() !== '';
}

/**
 * Shows an error message for a form field
 * @param {HTMLElement} input - Input element
 * @param {string} message - Error message to display
 */
function showError(input, message) {
    const formGroup = input.closest('.form-group');
    if (!formGroup) return;
    
    // Remove any existing error
    const existingError = formGroup.querySelector('.form-error');
    if (existingError) {
        existingError.remove();
    }
    
    // Add error class to input
    input.classList.add('error');
    input.setAttribute('aria-invalid', 'true');
    
    // Create and append error message
    const errorDiv = document.createElement('div');
    errorDiv.className = 'form-error';
    errorDiv.textContent = message;
    errorDiv.setAttribute('role', 'alert');
    formGroup.appendChild(errorDiv);
}

/**
 * Clears error message for a form field
 * @param {HTMLElement} input - Input element
 */
function clearError(input) {
    const formGroup = input.closest('.form-group');
    if (!formGroup) return;
    
    input.classList.remove('error');
    input.removeAttribute('aria-invalid');
    
    const existingError = formGroup.querySelector('.form-error');
    if (existingError) {
        existingError.remove();
    }
}

/**
 * Shows a success message for a form field
 * @param {HTMLElement} input - Input element
 * @param {string} message - Success message to display
 */
function showSuccess(input, message) {
    const formGroup = input.closest('.form-group');
    if (!formGroup) return;
    
    clearError(input);
    
    const successDiv = document.createElement('div');
    successDiv.className = 'form-success';
    successDiv.textContent = message;
    successDiv.setAttribute('role', 'status');
    formGroup.appendChild(successDiv);
}

/**
 * Validates a form field based on its type and attributes
 * @param {HTMLElement} input - Input element to validate
 * @returns {boolean} - True if valid, false otherwise
 */
function validateField(input) {
    const value = input.value;
    const type = input.type;
    const required = input.hasAttribute('required');
    
    clearError(input);
    
    // Check required
    if (required && !validateRequired(value)) {
        showError(input, 'This field is required');
        return false;
    }
    
    // Skip further validation if field is empty and not required
    if (!required && value.trim() === '') {
        return true;
    }
    
    // Type-specific validation
    if (type === 'email' && !validateEmail(value)) {
        showError(input, 'Please enter a valid email address');
        return false;
    }
    
    if (type === 'tel' && !validatePhone(value)) {
        showError(input, 'Please enter a valid phone number');
        return false;
    }
    
    // Check minlength
    const minLength = input.getAttribute('minlength');
    if (minLength && value.length < parseInt(minLength)) {
        showError(input, `Must be at least ${minLength} characters`);
        return false;
    }
    
    // Check pattern
    const pattern = input.getAttribute('pattern');
    if (pattern) {
        const regex = new RegExp(pattern);
        if (!regex.test(value)) {
            const title = input.getAttribute('title') || 'Invalid format';
            showError(input, title);
            return false;
        }
    }
    
    return true;
}

/**
 * Sets up real-time validation for form inputs
 * @param {HTMLFormElement} form - Form element
 */
function setupFormValidation(form) {
    const inputs = form.querySelectorAll('input, textarea, select');
    
    inputs.forEach(input => {
        // Validate on blur
        input.addEventListener('blur', function() {
            validateField(this);
        });
        
        // Clear error on input
        input.addEventListener('input', function() {
            if (this.classList.contains('error')) {
                clearError(this);
            }
        });
    });
    
    // Validate on submit
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        let isValid = true;
        inputs.forEach(input => {
            if (!validateField(input)) {
                isValid = false;
            }
        });
        
        if (isValid) {
            // Form is valid, you can submit it
            console.log('Form is valid, ready to submit');
            // In a real application, you would submit the form data here
            showFormSuccess(form);
        } else {
            // Focus on first error
            const firstError = form.querySelector('.error');
            if (firstError) {
                firstError.focus();
            }
        }
    });
}

/**
 * Shows a success message after form submission
 * @param {HTMLFormElement} form - Form element
 */
function showFormSuccess(form) {
    const alert = document.createElement('div');
    alert.className = 'alert alert-success';
    alert.textContent = 'Thank you! Your submission has been received.';
    alert.setAttribute('role', 'alert');
    
    form.insertBefore(alert, form.firstChild);
    
    // Reset form after short delay
    setTimeout(() => {
        form.reset();
        alert.remove();
    }, 3000);
}

// Initialize form validation on page load
document.addEventListener('DOMContentLoaded', function() {
    const forms = document.querySelectorAll('form[data-validate]');
    forms.forEach(form => setupFormValidation(form));
});
