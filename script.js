(() => {
  'use strict';

  const t = s => (window.g4bT ? window.g4bT(s) : s);
  const motion = window.matchMedia('(prefers-reduced-motion: reduce)');
  const desktop = window.matchMedia('(min-width: 761px)');
  const menuToggle = document.querySelector('.menu-toggle');
  const mobileMenu = document.querySelector('#mobile-menu');
  const readingProgress = document.querySelector('.reading-progress');

  function closeMenu(returnFocus = false) {
    menuToggle.setAttribute('aria-expanded', 'false');
    menuToggle.setAttribute('aria-label', t('Otwórz menu'));
    mobileMenu.hidden = true;
    if (returnFocus) menuToggle.focus();
  }

  menuToggle.addEventListener('click', () => {
    const open = menuToggle.getAttribute('aria-expanded') !== 'true';
    menuToggle.setAttribute('aria-expanded', String(open));
    menuToggle.setAttribute('aria-label', t(open ? 'Zamknij menu' : 'Otwórz menu'));
    mobileMenu.hidden = !open;
  });
  mobileMenu.querySelectorAll('a').forEach(link => link.addEventListener('click', () => closeMenu()));
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && !mobileMenu.hidden) closeMenu(true);
  });
  document.addEventListener('click', event => {
    if (!mobileMenu.hidden && !event.target.closest('.header')) closeMenu();
  });
  desktop.addEventListener('change', () => {
    if (desktop.matches) closeMenu();
  });

  let ticking = false;
  function updateReadingProgress() {
    const distance = document.documentElement.scrollHeight - window.innerHeight;
    readingProgress.style.transform = `scaleX(${distance > 0 ? Math.max(0, Math.min(1, window.scrollY / distance)) : 0})`;
    ticking = false;
  }
  window.addEventListener('scroll', () => {
    if (!ticking) {
      ticking = true;
      requestAnimationFrame(updateReadingProgress);
    }
  }, { passive: true });
  window.addEventListener('resize', updateReadingProgress);
  updateReadingProgress();

  const tourVisual = document.querySelector('.tour-visual');
  const screens = [...document.querySelectorAll('.tour-screen')];
  const steps = [...document.querySelectorAll('.tour-step')];
  const tourButtons = [...document.querySelectorAll('[data-step-target]')];
  const stageNumber = document.querySelector('.tour-stage-number');
  const currentNumber = document.querySelector('.current-number');
  const caption = document.querySelector('.tour-caption');
  const calloutKicker = document.querySelector('.tour-callout small');
  const calloutTitle = document.querySelector('.tour-callout strong');
  const calloutIcon = document.querySelector('.tour-callout-icon use');
  const stages = [
    { name: 'Twój trening', kicker: 'TWÓJ TRENING', title: 'Plan. Gotowy na dziś.', icon: '#i-dumbbell' },
    { name: 'Twoje odżywianie', kicker: 'TWOJE ODŻYWIANIE', title: 'Makro? Wszystko jasne.', icon: '#i-food' },
    { name: 'Twój trener AI', kicker: 'TWÓJ TRENER AI', title: 'Wsparcie po Twojej stronie.', icon: '#i-spark' }
  ];
  let activeStage = -1;

  function setStage(index) {
    if (index === activeStage) return;
    activeStage = index;
    const stage = stages[index];
    tourVisual.dataset.stage = String(index);
    stageNumber.textContent = currentNumber.textContent = String(index + 1).padStart(2, '0');
    caption.textContent = t(stage.name);
    calloutKicker.textContent = t(stage.kicker);
    calloutTitle.textContent = t(stage.title);
    calloutIcon.setAttribute('href', stage.icon);
    screens.forEach((screen, i) => {
      screen.classList.toggle('active', i === index);
      screen.setAttribute('aria-hidden', String(i !== index));
    });
    tourButtons.forEach((button, i) => {
      button.classList.toggle('active', i === index);
      if (i === index) button.setAttribute('aria-current', 'step');
      else button.removeAttribute('aria-current');
    });
  }
  setStage(0);
  window.g4bRefreshStage = () => { const i = activeStage; activeStage = -1; setStage(i < 0 ? 0 : i); };

  tourButtons.forEach(button => {
    button.addEventListener('click', () => {
      const index = Number(button.dataset.stepTarget);
      setStage(index);
      steps[index].scrollIntoView({ behavior: motion.matches ? 'instant' : 'smooth', block: 'center' });
    });
  });

  // Tour selection is independent of the animation library and never captures scrolling.
  const stepObserver = new IntersectionObserver(entries => {
    if (!desktop.matches) return;
    entries.forEach(entry => {
      if (entry.isIntersecting) setStage(Number(entry.target.dataset.step));
    });
  }, { rootMargin: '-45% 0px -45% 0px', threshold: 0 });
  steps.forEach(step => stepObserver.observe(step));

  if (!window.gsap || !window.ScrollTrigger) return;
  gsap.registerPlugin(ScrollTrigger);
  const animations = gsap.matchMedia();
  animations.add('(prefers-reduced-motion: no-preference)', () => {
    // Content is visible in HTML; animations progressively enhance it.
    const entrance = gsap.timeline({ defaults: { ease: 'power3.out' } });
    entrance.from('.hero-enter', { y: 18, opacity: 0, duration: .7, stagger: .09 })
      .from('.hero-disc, .orbit', { scale: .94, opacity: 0, duration: .9 }, .05)
      .from('.hero-phone-front', { y: 35, opacity: 0, duration: .95 }, .12)
      .from('.hero-phone-back', { y: 48, opacity: 0, duration: 1 }, .2)
      .from('.floating-note', { y: 15, opacity: 0, duration: .6, stagger: .12 }, .65)
      .from('.hero-visual-caption, .hero-star', { opacity: 0, duration: .6 }, .8);

    gsap.utils.toArray('.reveal').forEach(element => {
      gsap.from(element, {
        y: 25,
        opacity: 0,
        duration: .7,
        ease: 'power2.out',
        scrollTrigger: { trigger: element, start: 'top 94%', once: true }
      });
    });

    const chartPath = document.querySelector('.chart-line');
    const pathLength = chartPath.getTotalLength();
    gsap.fromTo(chartPath, { strokeDasharray: pathLength, strokeDashoffset: pathLength }, {
      strokeDashoffset: 0,
      duration: 1.8,
      ease: 'power2.out',
      scrollTrigger: { trigger: '.analytics-card', start: 'top 85%', once: true }
    });
    gsap.from('.chart-area', {
      opacity: 0,
      duration: 1.4,
      ease: 'power1.out',
      scrollTrigger: { trigger: '.analytics-card', start: 'top 85%', once: true }
    });

    return () => entrance.kill();
  });

  animations.add('(min-width: 761px) and (prefers-reduced-motion: no-preference)', () => {
    gsap.to('.hero-disc', {
      y: 35,
      ease: 'none',
      scrollTrigger: { trigger: '.hero', start: 'top top', end: 'bottom top', scrub: .7 }
    });
    gsap.to('.download-art > img', {
      rotation: -2,
      y: -10,
      ease: 'none',
      scrollTrigger: { trigger: '.download-card', start: 'top bottom', end: 'bottom top', scrub: 1 }
    });
  });

  document.fonts.ready.then(() => ScrollTrigger.refresh());
  window.addEventListener('load', () => ScrollTrigger.refresh(), { once: true });
})();
