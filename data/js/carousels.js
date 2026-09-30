;(function () { /*! Asciidoctor Carousels | Copyright (c) 2026-present Asciidoctor Carousels contributors | MIT License */
  'use strict'

  var forEach = Array.prototype.forEach
  var slice = Array.prototype.slice

  init(document.querySelectorAll('.carousel'))

  function init (carousels) {
    forEach.call(carousels, function (carousel) {
      var stage = carousel.querySelector('.carousel-stage')
      var track = carousel.querySelector('.carousel-track')
      var slides = slice.call(carousel.querySelectorAll('.carousel-slide'))
      if (!stage || !track || !slides.length) return

      var config = stage.dataset || {}
      var activeIndex = clamp(parseInt(config.activeSlide || '1', 10) - 1, 0, slides.length - 1)
      var interval = parsePositiveInt(config.interval || '5000', 5000)
      var autoplay = config.autoplay === 'true'
      var loop = config.loop !== 'false'
      var keyboard = config.keyboard !== 'false'
      var touch = config.touch !== 'false'
      var pauseOnHover = config.pauseOnHover === 'true'
      var isFade = carousel.classList.contains('is-fade')
      var timer

      slides.forEach(function (slide) { slide.classList.remove('is-hidden') })
      if (keyboard) stage.setAttribute('tabindex', '0')

      function setActive (index, skipFocus) {
        activeIndex = clamp(index, 0, slides.length - 1)
        slides.forEach(function (slide, idx) {
          var active = idx === activeIndex
          slide.classList[active ? 'add' : 'remove']('is-active')
          slide.setAttribute('aria-hidden', active ? 'false' : 'true')
        })
        if (!isFade) track.style.transform = 'translateX(-' + activeIndex * 100 + '%)'
        forEach.call(carousel.querySelectorAll('.carousel-indicator'), function (indicator, idx) {
          indicator.classList[idx === activeIndex ? 'add' : 'remove']('is-active')
        })
        if (!skipFocus && keyboard) stage.focus()
      }

      function next () {
        var target = activeIndex + 1
        if (target >= slides.length) target = loop ? 0 : slides.length - 1
        setActive(target)
        if (!loop && target === slides.length - 1 && timer) stop()
      }

      function prev () {
        var target = activeIndex - 1
        if (target < 0) target = loop ? slides.length - 1 : 0
        setActive(target)
      }

      function go (index) {
        setActive(index)
        stop()
        if (autoplay) start()
      }

      function start () {
        if (timer) stop()
        timer = window.setInterval(next, interval)
      }

      function stop () {
        if (!timer) return
        window.clearInterval(timer)
        timer = undefined
      }

      forEach.call(carousel.querySelectorAll('.carousel-control'), function (control) {
        control.addEventListener('click', function () {
          control.dataset.carouselAction === 'prev' ? prev() : next()
        })
      })

      forEach.call(carousel.querySelectorAll('.carousel-indicator'), function (indicator) {
        indicator.addEventListener('click', function () {
          go(parseInt(indicator.dataset.carouselIndex, 10))
        })
      })

      if (keyboard) {
        stage.addEventListener('keydown', function (e) {
          if (e.key === 'ArrowLeft') prev()
          else if (e.key === 'ArrowRight') next()
        })
      }

      if (touch) {
        var startX
        stage.addEventListener('pointerdown', function (e) { startX = e.clientX })
        stage.addEventListener('pointerup', function (e) {
          if (startX === undefined) return
          var delta = e.clientX - startX
          if (Math.abs(delta) > 30) delta < 0 ? next() : prev()
          startX = undefined
        })
      }

      if (autoplay) start()
      if (pauseOnHover) {
        carousel.addEventListener('mouseenter', stop)
        carousel.addEventListener('mouseleave', function () { if (autoplay) start() })
      }

      setActive(activeIndex, true)
      carousel.classList.remove('is-loading')
      carousel.classList.add('is-loaded')
    })
  }

  function clamp (value, min, max) {
    return Math.min(max, Math.max(min, value))
  }

  function parsePositiveInt (value, fallback) {
    var parsed = parseInt(value, 10)
    return parsed > 0 ? parsed : fallback
  }
})()
