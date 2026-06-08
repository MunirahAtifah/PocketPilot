/**
 * ============================================================================
 * PASSWORD MASKING UTILITY
 * ============================================================================
 * 
 * Purpose: Mask passwords for display in staff/admin interfaces
 * The actual password remains unchanged in the database
 * 
 * Usage: 
 *   var masked = maskPassword("mypassword123");
 *   // Returns: "m***7" (first char + asterisks + last char)
 * 
 * ============================================================================
 */

/**
 * Mask a password for safe display in staff interface
 * Shows only first and last character, replaces middle with asterisks
 * 
 * @param {string} password - The actual password to mask
 * @returns {string} Masked password like "a****b"
 * 
 * @example
 * maskPassword("password123") // Returns "p**********3"
 * maskPassword("abc") // Returns "a*c"
 * maskPassword("ab") // Returns "a*"
 * maskPassword("a") // Returns "a"
 * maskPassword("") // Returns ""
 */
function maskPassword(password) {
  // Handle empty or short passwords
  if (!password || password.length === 0) {
    return "";
  }
  
  if (password.length === 1) {
    return password;
  }
  
  if (password.length === 2) {
    return password[0] + "*";
  }
  
  // For passwords 3+ characters: first char + asterisks + last char
  const firstChar = password[0];
  const lastChar = password[password.length - 1];
  const asterisks = "*".repeat(password.length - 2);
  
  return firstChar + asterisks + lastChar;
}

/**
 * Display masked password with tooltip in HTML
 * 
 * @param {string} password - The actual password to mask
 * @param {string} tooltipText - Optional tooltip text
 * @returns {string} HTML string with masked password and tooltip
 * 
 * @example
 * var html = getMaskedPasswordHTML("password123", "Staff can view masked passwords");
 */
function getMaskedPasswordHTML(password, tooltipText = "Password masked for security") {
  const masked = maskPassword(password);
  
  return `
    <span class="password-masked">
      ${masked}
      <span class="password-tooltip">
        <span class="tooltiptext">${tooltipText}</span>
        ℹ️
      </span>
    </span>
    <div class="password-masked-info">
      (Database contains actual password - Staff view only)
    </div>
  `;
}

/**
 * Create masked password element and insert into DOM
 * 
 * @param {string} elementId - ID of element to insert masked password into
 * @param {string} password - The actual password to mask
 * @param {string} tooltipText - Optional tooltip text
 */
function displayMaskedPassword(elementId, password, tooltipText = "Password masked for security") {
  const element = document.getElementById(elementId);
  if (element) {
    element.innerHTML = getMaskedPasswordHTML(password, tooltipText);
  }
}

/**
 * Security reminder for staff using password displays
 */
function showPasswordSecurityReminder() {
  const message = `
⚠️  SECURITY REMINDER FOR STAFF

✓ Passwords are MASKED in this interface for security
✓ Actual passwords are SAFELY STORED in database
✓ Users can reset their own passwords
✓ Only view masked passwords when absolutely necessary
✓ Never share actual passwords with users via email or chat

Staff responsibilities:
- Respect user privacy
- Don't attempt to unmask passwords
- Guide users to use "forgot password" feature
- Report any security concerns immediately
  `;
  
  console.log(message);
}

// Display security reminder when page loads
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', showPasswordSecurityReminder);
} else {
  showPasswordSecurityReminder();
}

/**
 * Validate password complexity (for new registrations)
 * 
 * @param {string} password - Password to validate
 * @returns {object} Validation result with status and messages
 */
function validatePasswordComplexity(password) {
  const result = {
    isValid: true,
    strength: "weak",
    messages: []
  };
  
  if (!password) {
    result.isValid = false;
    result.messages.push("Password is required");
    return result;
  }
  
  if (password.length < 6) {
    result.isValid = false;
    result.messages.push("Password must be at least 6 characters");
  }
  
  if (password.length >= 6 && password.length < 8) {
    result.strength = "weak";
    result.messages.push("Password is short, consider using 8+ characters");
  } else if (password.length >= 8) {
    result.strength = "strong";
  }
  
  if (!/[a-z]/.test(password)) {
    result.messages.push("Add lowercase letters for better security");
  }
  
  if (!/[A-Z]/.test(password)) {
    result.messages.push("Add uppercase letters for better security");
  }
  
  if (!/[0-9]/.test(password)) {
    result.messages.push("Add numbers for better security");
  }
  
  if (result.messages.length === 0 && password.length >= 8) {
    result.strength = "strong";
  }
  
  return result;
}

/**
 * ============================================================================
 * USAGE EXAMPLES IN JSP/HTML
 * ============================================================================
 * 
 * Example 1: Display masked password in a table
 * ─────────────────────────────────────────────
 * <td>
 *   <span id="password_display_1"></span>
 * </td>
 * <script>
 *   displayMaskedPassword('password_display_1', '<%= userPassword %>');
 * </script>
 * 
 * Example 2: HTML with masked password
 * ─────────────────────────────────────
 * <div class="user-password">
 *   <%= getMaskedPasswordHTML(userPassword, "Staff-only masked view") %>
 * </div>
 * 
 * Example 3: Using mask function directly
 * ──────────────────────────────────────────
 * <span class="password-masked">
 *   <%= maskPassword(userPassword) %>
 * </span>
 * 
 * Example 4: Password validation
 * ───────────────────────────────
 * var validation = validatePasswordComplexity("password123");
 * if (validation.isValid) {
 *   console.log("Password is valid");
 * }
 * 
 * ============================================================================
 */

// Export for use in Node.js/CommonJS environments (if needed)
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    maskPassword,
    getMaskedPasswordHTML,
    displayMaskedPassword,
    showPasswordSecurityReminder,
    validatePasswordComplexity
  };
}
