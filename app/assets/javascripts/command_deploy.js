$(document).ready(function() {

  var command_var_template = ' \
    <label for="cmd_var[{{VARIABLE-KEY}}]">{{VARIABLE-KEY}}</label> \
    <input type="text" id="cmd_var_{{VARIABLE-KEY}}" class="command_var_val" name="cmd_var[{{VARIABLE-KEY}}]" data-key="{{VARIABLE-KEY}}" /> \
    <br /> \
  ';

  // --- On Selection of a command ---
  $('.select_command select').change(function() {
    cmd_id = $(this).val();

    // 1. Enable submit button
    $('#run_command').removeAttr('disabled');

    // 2. Get command text
    $cmd_preview_field = $('textarea.command_text');
    $cmd_template = "";
    $.post('/commands/' + cmd_id + '/get_command', function(data) {
      // Populate command content text
      $cmd_preview_field.text(data.data);
      cmd_template = data.data;
      // Show command contents div
      $(".command_preview").removeClass('hidden');
    });

    // 3. Get fields for command variables
    $.post('/commands/' + cmd_id + '/get_variables', function(data) {
      $('#command_variable_container').html('');
      if (data.data && data.data != '') {
        // Show command variables div
        $(".command_variables").removeClass('hidden');

        // Populate template variables fields, register autocomplete entries
        $.each(data.data, function(key, variable_item) {
          for (key in variable_item) {
            cv_html = command_var_template.replace(/{{VARIABLE-KEY}}/g, key);
            cv_html = cv_html.replace(/{{VARIABLE-VAL}}/g, variable_item[key])
            $('#command_variable_container').append(cv_html);
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

  // On entry of variable text, update the command preview field
  $('.command_var_val').live('keyup change', function() {
    cmd_var_keys = cmd_template.match(/{{((?!servers?|date|git(hub)?:).*?)}}/g); // Exempt certain special vars
    ctext = cmd_template;
    // Re-build the preview for each variable
    $.each(cmd_var_keys, function(index, v) {
      var_key = v.replace(/{{|}}/, '');
      var_field = $("#cmd_var_" + var_key);
      var_value = var_field.val();
      if (var_value != '') { // Ignore blank variables
        mustache_match = new RegExp(v, 'g')
        ctext = ctext.replace(mustache_match, var_value);
      }
    });
    $cmd_preview_field.val(ctext); // Update the preview field

    //$cmd_preview_field.val($cmd_template.replace(/{{(.*?)}}/g, "#cmd_var_$1"));
  });

  // Mustache template variable parsing helpers
  function fetch_git_branches() {

  }
  // Fills in server variables (Supplies a list of servers to a command as csv string)
  function assign_servers() {
    $('.command_server').each(function() {
      server = $(this).name().replace(/server\[.*\]/, "$1");
      console.log(server);
    });
  }

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

    if (servers.length < 1) {
      alert("You must choose one or more servers to receive the command or deployment.");
      return false;
    }

    if (($.inArray(environment.toLowerCase(), ["production", "live"]) != -1) && 
      !confirm("This command affects the production environment. Confirm?")) 
    {
      return false;
    }

    $('.running_command').addClass('inline_block');

    // Run Command/Deploy!
    $.ajax({
      type: 'POST',
      url: '/commands/' + cmd_id + '/run_command',
      data: {"variables": variables, "environment": environment, "servers": servers},
      datatype: 'json',
      success: function(data) {
        $('.running_command').fadeOut();
        console.log('-- AJAX response: --');
        console.log(data);
        $('section.command_results').fadeIn();
        $.each(data, function(i, result) {
          if (result.status == 0) {
            $('#command_result_log').append('<div class="alert-message message">Success!</div>');
          } else {
            $('#command_result_log').append('<div class="alert-message error">Failure!</div>');
          }
          $('#command_result_log').append('<div class="status_message">' + result.status_message + '</div>');
          $('#command_result_log').append('<div class="result_log">' + result.log_text + '</div>');
        });
      },
      error: function(data) {
        $('.running_command').fadeOut();
        $('section.command_results').fadeIn();
        $('#command_result_log').append('<div class="alert-message error">Failure!</div>');
        $.each(data, function(i, result) {
          $('#command_result_log').append('<div class="result_log">' + JSON.stringify(data) + '</div>');
        });
      },
    });

    return false; // Don't submit form
  });
});

