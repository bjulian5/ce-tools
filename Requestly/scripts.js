(() => {

  // Rules
  const scripts = [
    { exec: Auto_GitHub_SSO, site: 'https://github.com', timing: DOM_Loaded },
    { exec: Auto_Login_Admin2, site: 'https://www.yext.com/users/accessdenied', timing: DOM_Loaded },
    { exec: Auto_Login_Okta, site: 'https://yext.okta.com/login/login.htm', timing: Element_Loaded.bind(this, '#okta-signin-password') },
    { exec: Auto_Login_Smartling, site: 'https://sso.smartling.com/auth/realms/Smartling/protocol/openid-connect/auth', timing: DOM_Loaded },
    { exec: Fix_Pages_Admin_Query, site: 'https://www.yext.com/pagesadmin', timing: DOM_Loaded },
    { exec: No_JIRA_Notification_Badge, site: 'https://yexttest.atlassian.net', timing: Immediately }
  ];


  for (let script of scripts) {
    if (window.location.href.startsWith(script.site)) {
      script.timing(script.exec);
    }
  }

  // Timing Functions
  function Immediately(cb) {
    cb();
  }

  function DOM_Loaded(cb) {
    if (['loaded', 'interactive', 'complete'].includes(document.readyState)) {
      cb();
    } else {
      window.addEventListener('DOMContentLoaded', cb);
    }
  }

  function Page_Loaded(cb) {
    if (document.readyState == 'complete') {
      cb();
    } else {
      window.addEventListener('load', cb);
    }
  }

  function Element_Loaded(querySelector, cb) {
    if (document.querySelector(querySelector)) {
      cb();
    } else {
      window.nodes = [];

      function elementInsertedListener(e) {
        window.nodes.push(e.target);
        if (e.target && ((e.target.matches && e.target.matches(querySelector)) || (e.target.querySelector && e.target.querySelector(querySelector)))) {
          console.log('******* Match found!');
          window.removeEventListener('DOMNodeInserted', elementInsertedListener);
          cb();
        }
      }

      console.log('Adding DOM listener');
      window.addEventListener('DOMNodeInserted', elementInsertedListener);
    }
  }


  // Scripts
  function Auto_GitHub_SSO() {
    const form = document.querySelector('form');
    if (form && form.action.startsWith('https://github.com/orgs/yext/saml/initiate')) {
      form.submit();
    }
  }

      
  function Auto_Login_Admin2() {
    document.querySelector('.js-signin-url').click();
  }


  function Auto_Login_Okta() {
    const pwInput = document.getElementById('okta-signin-password');
    if (pwInput.value) {
      setTimeout(() => pwInput.form.dispatchEvent(new Event('submit')), 100);
    } else {
      pwInput.addEventListener('change', () => {
        if (pwInput.value) {
          setTimeout(() => pwInput.form.dispatchEvent(new Event('submit')), 100);
        }
      });
    }
  }


  function Auto_Login_Smartling() {
    document.getElementById('zocial-google').click();
  }


  function Fix_Pages_Admin_Query() {
    const input = document.querySelector('#sites_table_filter input');
    input.value = (new URLSearchParams(window.location.search)).get('query');
    input.dispatchEvent(new Event('keyup'));
  }


  function No_JIRA_Notification_Badge() {
    const style = document.createElement('style');
    style.innerHTML = '.css-v2uvap { display: none; }';
    document.head.appendChild(style);
  }

})();