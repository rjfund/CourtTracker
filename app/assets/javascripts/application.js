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
//= require_tree .
//

$(document).on('ready', function(){
  $('.hearings').hide();
  $('.documents').hide();
  $('.cases').show();

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
})
