$(document).ready(function () {
    $.getJSON('./public/static/groups.json', function (groupsJson) {
        var stringified = JSON.stringify(groupsJson);
        var groups = JSON.parse(stringified);
        var select = $('<select class="form-control form-control-sm"></select>').attr("id", "groupSelect").attr("name", "groups");
        select.append($("<option></option>").attr("value", "").text("All groups"));
        $.each(groups, function (index, group) {
            select.append($("<option></option>").attr("value", group).text(group));
        });
        $("#groupSelector").html(select);
    });

    $.getJSON('./public/static/suites.json', function (suitesJson) {
        var stringified = JSON.stringify(suitesJson);
        var suites = JSON.parse(stringified);
        var select = $('<select class="form-control form-control-sm"></select>').attr("id", "suiteSelect").attr("name", "suites");
        $.each(suites, function (index, suite) {
            select.append($("<option></option>").attr("value", suite).text(suite));
        });
        $("#suiteSelector").html(select);
    });

    $.getJSON('./public//static/branches.json', function (branchesJson) {
        var stringified = JSON.stringify(branchesJson);
        var branches = JSON.parse(stringified);
        var select = $('<select class="form-control form-control-sm"></select>').attr("id", "branchSelect").attr("name", "branches");
        $.each(branches, function (index, branch) {
            select.append($("<option></option>").attr("value", branch).text(branch));
        });
        $("#branchSelector").html(select);
    });
});

$(function () {
    $("#overrideHostCheckBox").click(function () {
        if ($("#overrideHostCheckBox").is(':checked')) {
            $("#ipField").attr('style', 'visibility: visible;');
        } else {
            $("#ipField").attr('style', 'visibility: hidden;');
        }
    });
});

$(function () {
    $(document).ready(function () {
        $("#newTestRunButton").click(function () {
            $("#newTestRunModal").modal();
        });
    });
});

$(function () {
    $("#runTests").click(function () {
        $(".close").click();

        var group = $("#groupSelect").val();
        var suite = $("#suiteSelect").val();
        var branch = $("#branchSelect").val();
        var overrideHost = $("#overrideHostCheckBox").is(':checked')
        var invIP = $("#ipField").val();


        var runParams ='&variables[RUN_GROUPS]=' + group +
            '&variables[ENV_OVERRIDE_HOST]=' + overrideHost +
            '&variables[ENV_IP]=' + invIP +
            '&variables[RUN_SUITE]=' + suite;

        console.log(runParams);

        $.ajax({
            type: 'POST',
            url: 'https://' + branch + '/trigger/pipeline?token=' + runParams,
            processData: false,
            contentType: false,
            dataType: 'json',
            success: function (data) {
                console.dir(data);
                showPipelineSuccessMessage(data.web_url);
            },
            error: function (data) {
                console.dir(data);
                showPipelineErrorMessage(data.responseText);
            },
        });
    });

});

function showPipelineErrorMessage(responseText) {
    var alertMessage = '<span></span><p>' + responseText + '</p>';
    $("#alertMessage").html(alertMessage);
    $(".alert").attr('style', 'background-color: red; display: block;');
};

function showPipelineSuccessMessage(pipelineUrl) {
    var pipelineLink = pipelineUrl;
    var alertMessage = '<span>' +
                            'Тесты запущены. Результат появится на это странице после завершения пайплайна:' +
                        '</span>' +
                        '<p>' +
                            '<a href="' + pipelineLink + '" target="_blank">' + pipelineLink +
                              '<img class="icon-mini" src="/static/icons/external-link-alt-solid.svg" />' +
                            '</a>'+
                        '</p>';
                        
    $("#alertMessage").html(alertMessage);
    $(".alert").attr('style', 'display: block;');
};

$(document).ready(function () {
    let listDiv = document.getElementById('list');
    let table = listDiv.parentNode;

    $.getJSON('./public/history.json', function (historyJson) {
        var stringified = JSON.stringify(historyJson);
        var pipelines = JSON.parse(stringified);
        console.log(pipelines);

        pipelines.sort((a, b) => b.pipelineId - a.pipelineId);

        pipelines.map(function (pipeline) {
            var runGroups = pipeline.runGroups == "" ? 'All' : pipeline.runGroups;
            var reportUrl = 'public/' + pipeline.locale + '/' + pipeline.pipelineId;

            var pipelineLink = '<a href="https://' +
                    pipeline.pipelineId + '" target="_blank">' + pipeline.pipelineId + '</a>';

            var upstreamPipelineLink = pipeline.upstreamPipelineId == "null" ?
                'manual' :
                '<a href="https://' +
                    pipeline.upstreamPipelineId + '" target="_blank">' + pipeline.upstreamPipelineId +
                '</a>';

            var environmentUrl = '<a href="' + pipeline.envUrl + '" target="_blank">' + pipeline.envUrl + '</a>';

            table.innerHTML += '<tr>' +
                    '<td class="locale">' +
                        '<img class="flagIcon" src="./public/static/flags/' + pipeline.locale + '.svg" title="' + pipeline.locale.toUpperCase() + '">' +
                    '</td>' +
                    '<td>' + pipeline.appVersion + '</td>' +
                    '<td>' + pipeline.dateTime + '</td>' +
                    '<td>' +
                        '<a href="' + reportUrl + '" target="_blank">' +
                            '<img class="icon-mini" src="./public/static/icons/external-link-alt-solid.svg" />' +
                        '</a>' +
                    '</td>' +
                    '<td>' + pipelineLink + '</td>' +
                    '<td>' + runGroups + '</td>' +
                    '<td>' + environmentUrl + '</td>' +
                    '<td>' + pipeline.envOverrideHost + '</td>' +
                    '<td>' + pipeline.device + '</td>' +
                    '<td>' + upstreamPipelineLink + '</td>' +
                    '<td>' +
                        '<a href="' + reportUrl + '/params.json" target="_blank">' +
                            '<img class="icon-mini" src="./public/static/icons/external-link-alt-solid.svg" />' +
                        '</a>' +
                    '</td>' +
                '</tr>';
        })
    });
});