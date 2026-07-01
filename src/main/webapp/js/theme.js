// PocketPilot Theme Selector & Loader Script
(function () {
    // 1. Immediately apply the saved theme to prevent white flash
    const savedTheme = localStorage.getItem('pocketpilot-theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);

    // 2. Append the floating theme switch once the DOM is fully parsed
    document.addEventListener('DOMContentLoaded', function () {
        const toggleBtn = document.createElement('button');
        toggleBtn.className = 'theme-float-toggle';
        toggleBtn.id = 'themeFloatToggle';
        toggleBtn.setAttribute('aria-label', 'Toggle light/dark theme');
        toggleBtn.innerHTML = savedTheme === 'dark' ? '☀️' : '🌙';

        // Add styling for the floating button dynamically
        const style = document.createElement('style');
        style.textContent = `
            .theme-float-toggle {
                position: fixed;
                bottom: 25px;
                right: 25px;
                width: 50px;
                height: 50px;
                border-radius: 50%;
                background: var(--primary-color, #6B46C1);
                color: #ffffff;
                border: none;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 22px;
                z-index: 10000;
                transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275), background-color 0.3s;
            }
            .theme-float-toggle:hover {
                transform: scale(1.1);
                background: var(--primary-hover, #8B5CF6);
            }
            .theme-float-toggle:active {
                transform: scale(0.95);
            }
        `;
        document.head.appendChild(style);
        document.body.appendChild(toggleBtn);

        // 3. Toggle button event click handler
        toggleBtn.addEventListener('click', function () {
            const currentTheme = document.documentElement.getAttribute('data-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            
            document.documentElement.setAttribute('data-theme', newTheme);
            localStorage.setItem('pocketpilot-theme', newTheme);
            toggleBtn.innerHTML = newTheme === 'dark' ? '☀️' : '🌙';
        });
    });
})();
