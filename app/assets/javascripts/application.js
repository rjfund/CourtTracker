// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
//

$(document).on('ready', function(){
  $('.documents').hide();
  if ($('.cases').length) {
    $('.cases').show();
    $('.hearings').hide();
  } else {
    $('.cases').hide();
    $('.hearings').show();
  }

  $('.old').hide();
  $('.new').show();

  $('li.new-link').on('click', function(){
    $('.tabs li').removeClass('is-active');
    $(this).addClass('is-active');

    $('.new').show();
    $('.old').hide();
  })

  $('li.old-link').on('click', function(){
    $('.tabs li').removeClass('is-active');
    $(this).addClass('is-active');

    $('.old').show();
    $('.new').hide();
  })


  $('li.cases-link').on('click', function(){
    $('.tabs li').removeClass('is-active');
    $(this).addClass('is-active');

    $('.cases').show();
    $('.hearings').hide();
    $('.documents').hide();
  })

  $('li.hearings-link').on('click', function(e){
    $('.tabs li').removeClass('is-active');
    $(this).addClass('is-active');

    $('.cases').hide();
    $('.hearings').show();
    $('.documents').hide();
  })

  $('li.documents-link').on('click', function(e){
    $('.tabs li').removeClass('is-active');
    $(this).addClass('is-active');

    $('.cases').hide();
    $('.hearings').hide();
    $('.documents').show();
  })

  $('#new-case-button').on('click', function(e){
    e.preventDefault()
    $('#new-case-form').toggleClass('is-active')
  })

  $('#new-case-form.modal button.close-modal').on('click', function(e){
    e.preventDefault()
    $('#new-case-form').toggleClass('is-active')
  })

  $('.navbar-burger').on('click', function(e){
    $(this).toggleClass('is-active')
    $('.navbar-menu').toggleClass('is-active')
  })

  $('.notification button.delete').on('click', function(e){
    $(this).parent().removeClass("slide-in")
    $(this).parent().addClass("slide-out")
    $(this).parent().hide(500)
  })

  $('#info-button').on('click', function(e){
    e.preventDefault()
    $('#info-modal').toggleClass('is-active')
  })

  $('#info-modal button.close-modal').on('click', function(e){
    e.preventDefault();
    $('#info-modal').toggleClass('is-active');
  })

})



