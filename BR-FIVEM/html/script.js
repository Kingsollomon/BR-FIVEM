const soundsBase = '../sounds/';

let announceTimeout = null;

function playSound(file) {
  if (!file) return;
  const audio = new Audio(`${soundsBase}${file}`);
  audio.volume = 0.9;
  audio.play().catch(() => {});
}

window.addEventListener('message', (e) => {
  const { action, data } = e.data || {};
  if (!action) return;

  switch (action) {
    case 'updateKillFeed': {
      const feed = document.getElementById('killfeed');
      feed.innerHTML = '';
      (data || []).forEach(entry => {
        const div = document.createElement('div');
        div.className = 'entry';
        div.textContent = `${entry.name} (${entry.count})`;
        feed.appendChild(div);
      });
      break;
    }

    case 'announce': {
      const ann = document.getElementById('announce');
      ann.textContent = data || '';
      ann.style.opacity = '1';
      if (announceTimeout) clearTimeout(announceTimeout);
      announceTimeout = setTimeout(() => { ann.style.opacity = '0'; }, 4000);
      break;
    }

    case 'updateCircle': {
      const el = document.getElementById('circleTimer');
      const r = Math.floor(data || 0);
      el.textContent = `Safe zone radius: ${r} m`;
      break;
    }

    case 'preMatch': {
      const pre = document.getElementById('preMatch');
      pre.style.display = 'block';
      let cd = Number(data || 0);
      pre.textContent = `Match starts in ${cd}...`;
      const timer = setInterval(() => {
        cd--;
        pre.textContent = `Match starts in ${cd}...`;
        if (cd <= 0) {
          clearInterval(timer);
          pre.style.display = 'none';
        }
      }, 1000);
      break;
    }

    case 'endMatch': {
      const end = document.getElementById('endMatch');
      end.innerHTML = `<div class="title">Winner: ${data.winner}</div><div class="sub">Kills: ${data.kills}</div>`;
      end.style.display = 'block';
      break;
    }

    case 'playSound': {
      playSound(data);
      break;
    }

    default:
      break;
  }
});
