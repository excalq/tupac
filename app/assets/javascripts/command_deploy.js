$(document).ready(function() {

  var command_var_template = ' \
    <label for="cmd_var[{{VARIABLE-KEY}}]">{{VARIABLE-KEY}}</label> \
    <input type="text" id="cmd_var_{{VARIABLE-KEY}}" class="command_var_val" name="cmd_var[{{VARIABLE-KEY}}]" class="cmd_var" /> \
    <br /> \
  ';

  // --- On Selection of a command ---
  $('.select_command select').change(function() {

    // 1. Enable submit button
    $('#run_command').removeAttr('disabled');

    // 2. Get command text

    // 3. Get fields for command variables
    cmd_id = $(this).val();
    $.post('/commands/' + cmd_id + '/get_variables', function(data) {
      $('.command_variables').html('');
      if (data.data) {
        // Show command variables div
        $(".command_variables").removeClass('hidden');

        $.each(data.data, function(key, variable_item) {
          for (key in variable_item) {
            cv_html = command_var_template.replace(/{{VARIABLE-KEY}}/g, key);
            cv_html = cv_html.replace(/{{VARIABLE-VAL}}/g, variable_item[key])
            $('.command_variables').append(cv_html);
            $('#cmd_var_'+key).autocomplete({source: variable_item[key]});
            if (variable_item[key].length > 0) {
              $('#cmd_var_'+key).attr('placeholder', 'Type for Autocomplete...')
            }
          }
        });
      } else if (data.error) {
        console.log('ERROR: '+data.error)
      }
    });
  });


  // --- Running a command (Via AJAX) ---
  $('#command_deploy form').submit(function() {

    var environment = $('#environment_environment').val();
    var servers = [];
    $('.command_server:checked').each(function() {
      server = this.name.replace(/server\[(.*?)\]/, "$1");
      servers.push(server);
    });

    var variables = {};
    $(".command_var_val").each(function() {
      var_key = this.name.replace(/cmd_var\[(.*?)\]/, "$1");
      variables[var_key] = $(this).val();
    });

    // Run Command/Deploy!
    $.ajax({
      type: 'POST',
      url: '/commands/' + cmd_id + '/run_command',
      data: {"variables": variables, "environment": environment, "servers": servers},
      datatype: 'json',
      success: function(data) {
        console.log('-- AJAX response: --');
        console.log(data);
        $('section.command_results').fadeIn();
        $.each(data, function(i, result) {
          if (result.result == 0) {
            $('#command_result_log').append('<div class="alert-message message">Success!</div>');
          } else {
            $('#command_result_log').append('<div class="alert-message error">Failure!</div>');
          }
          $('#command_result_log').append('<div class="result_log">' + result.log_text + '</div>');
        });
      },
      error: function(data) {
        $('section.command_results').fadeIn();
        $('#command_result_log').append('<div class="alert-message error">Failure!</div>');
        $.each(data, function(i, result) {
          $('#command_result_log').append('<div class="result_log">' + JSON.stringify(data) + '</div>');
        });
      }
    });

    return false; // Don't submit form
  });
});

