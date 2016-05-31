$(function () {
    var seriesOptions = []
    var displaySeries = [0,1,2];
    function createChart() {
        $('#container').highcharts('StockChart', {
            rangeSelector: {
                selected: 6
            },
            yAxis: {
                labels: {
                    formatter: function () {
                        return (this.value > 0 ? ' + ' : '') + this.value + '%';
                    }
                },
                plotLines: [{
                    value: 0,
                    width: 2,
                    color: 'silver'
                }]
            },
            plotOptions: {
                series: {
                    compare: 'percent'
                }
            },
            tooltip: {
                pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.change}%)<br/>',
                valueDecimals: 2
            },
            series: seriesOptions
        });
    }
    function widget(n, tag){
        var html = '<tr><td><h3>EUR/' + tag.toUpperCase();
        html += '</h3></td><td><h3 id="'+tag+'-value">';
        html += '</h3></td></tr>';
        $('.table').append(html);

        var cur_data = seriesOptions[n].data;
        var cur_start = cur_data[0][1];
        var cur_end = cur_data[cur_data.length-1][1];
        var elem = $('#'+tag+'-value');
        elem.text(cur_end);

        var icon = 'minus' 
        if(cur_start < cur_end){
            icon = 'arrow-down'
        }
        else if(cur_start > cur_end) {
            icon = 'arrow-up'
        }
        elem.html('<span class="glyphicon glyphicon-'+icon+'"></span>' + elem.text());
    }

    $.getJSON('/fx_api?' + name.toLowerCase(),    function (data) {
        var opts = {}
        $.each(data.result.fx_data, function (i, name) {
             var elem = data.result.fx_data[i];
             $.each(elem, function(j){
                 if(j){
                     if(opts[j] == undefined)
                          opts[j] = [];
                     opts[j].push([Date.parse(elem[0]), elem[j]])
                 }
             });
        });
        $.each(displaySeries, function (i) {
	    seriesOptions[i] = {
		name: data.result.legend[i],
		data: opts[i+1]
	    };
            widget(i, data.result.legend[i]);
        });
	createChart();
    });
});
