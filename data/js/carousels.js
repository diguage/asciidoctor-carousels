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
      var progress = 0
      var lastTick

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

      function updateIndicatorProgress (value) {
        forEach.call(carousel.querySelectorAll('.carousel-indicator'), function (indicator) {
          var active = indicator.classList.contains('is-active')
          indicator.style.setProperty('--carousel-progress', active ? value : 0)
        })
      }

      function advance (direction, fromAutoplay) {
        var target = activeIndex + direction
        if (target >= slides.length) target = loop ? 0 : slides.length - 1
        if (target < 0) target = loop ? slides.length - 1 : 0
        setActive(target)
        progress = 0
        updateIndicatorProgress(0)
        if (!fromAutoplay && autoplay) start()
        else if (fromAutoplay && !loop && target === slides.length - 1) stop()
      }

      function next () { advance(1, false) }

      function prev () { advance(-1, false) }

      function go (index) {
        stop()
        setActive(index)
        progress = 0
        updateIndicatorProgress(0)
      }

      function start () {
        if (timer) stop()
        progress = 0
        lastTick = undefined
        updateIndicatorProgress(0)
        timer = window.requestAnimationFrame(tick)
      }

      function tick (now) {
        if (!autoplay) return
        if (lastTick === undefined) lastTick = now
        var elapsed = now - lastTick
        lastTick = now
        progress += elapsed / interval
        if (progress >= 1) advance(1, true)
        else updateIndicatorProgress(progress)
        if (timer) timer = window.requestAnimationFrame(tick)
      }

      function stop () {
        if (!timer) return
        window.cancelAnimationFrame(timer)
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
        carousel.addEventListener('mouseover', function (e) {
          var related = e.relatedTarget
          if (!related || !carousel.contains(related)) stop()
        })
        carousel.addEventListener('mouseout', function (e) {
          var related = e.relatedTarget
          if ((!related || !carousel.contains(related)) && autoplay) start()
        })
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
