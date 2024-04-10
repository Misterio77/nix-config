let
  thresholds = {
    mode = "percentage";
    steps = [
      {
        color = "text";
        value = null;
      }
      {
        color = "green";
        value = 0.01;
      }
      {
        color = "yellow";
        value = 75;
      }
      {
        color = "red";
        value = 90;
      }
    ];
  };
in {
  panels = [
    {
      gridPos = {
        h = 1;
        w = 24;
        x = 0;
        y = 0;
      };
      repeat = "hosts";
      repeatDirection = "h";
      title = "$hosts";
      type = "row";
    }
    {
      fieldConfig = {
        defaults = {
          decimals = 1;
          noValue = "Down";
          thresholds = {
            mode = "absolute";
            steps = [
              {
                color = "red";
                value = null;
              }
              {
                color = "green";
                value = 1;
              }
            ];
          };
          unit = "s";
        };
      };
      gridPos = {
        h = 7;
        w = 6;
        x = 0;
        y = 1;
      };
      options = {
        colorMode = "value";
        graphMode = "none";
        reduceOptions.calcs = ["last"];
        text.valueSize = 70;
        textMode = "value";
        wideLayout = true;
      };
      targets = [
        {
          expr = ''node_time_seconds{instance="$hosts"} - node_boot_time_seconds{instance="$hosts"}'';
          legendFormat = "__auto";
        }
      ];
      title = "Up time";
      type = "stat";
    }
    {
      fieldConfig = {
        defaults = {
          inherit thresholds;
          min = 0;
          noValue = "?";
          unit = "decbytes";
        };
      };
      gridPos = {
        h = 7;
        w = 6;
        x = 6;
        y = 1;
      };
      options.reduceOptions.calcs = ["lastNotNull"];
      targets = [
        {
          expr = ''avg by (device) (node_filesystem_size_bytes{instance="$hosts",mountpoint="/"} - node_filesystem_free_bytes{instance="$hosts",mountpoint="/"} > 0)'';
          legendFormat = "Used Space";
          refId = "Used Space";
        }
        {
          expr = ''avg by (device) (node_filesystem_size_bytes{instance="$hosts",mountpoint="/"} > 0)'';
          legendFormat = "Total Space";
          refId = "Total Space";
        }
      ];
      title = "Root disk usage";
      transformations = [
        {
          id = "configFromData";
          options = {
            applyTo = {
              id = "byFrameRefID";
              options = "Used Space";
            };
            configRefId = "Total Space";
            mappings = [
              {
                fieldName = "Total Space";
                handlerKey = "max";
              }
              {
                fieldName = "Time";
                handlerKey = "__ignore";
              }
            ];
          };
        }
      ];
      type = "gauge";
    }
    {
      fieldConfig = {
        defaults = {
          inherit thresholds;
          min = 0;
          noValue = "?";
          unit = "decbytes";
        };
      };
      gridPos = {
        h = 7;
        w = 5;
        x = 12;
        y = 1;
      };
      options.reduceOptions.calcs = ["last"];
      targets = [
        {
          expr = ''node_memory_MemTotal_bytes{instance="$hosts"} - node_memory_MemAvailable_bytes{instance="$hosts"}'';
          legendFormat = "Used Memory";
          refId = "Used Memory";
        }
        {
          expr = ''node_memory_MemTotal_bytes{instance="$hosts"}'';
          legendFormat = "Total Memory";
          refId = "Total Memory";
        }
      ];
      title = "RAM Usage";
      transformations = [
        {
          id = "configFromData";
          options = {
            applyTo = {
              id = "byFrameRefID";
              options = "Used Memory";
            };
            configRefId = "Total Memory";
            mappings = [
              {
                fieldName = "Total Memory";
                handlerKey = "max";
              }
              {
                fieldName = "Time";
                handlerKey = "__ignore";
              }
            ];
          };
        }
      ];
      type = "gauge";
    }
    {
      fieldConfig = {
        defaults = {
          inherit thresholds;
          min = 0;
          noValue = "?";
          unit = "percentunit";
        };
      };
      gridPos = {
        h = 7;
        w = 5;
        x = 17;
        y = 1;
      };
      options.reduceOptions.calcs = ["last"];
      targets = [
        {
          expr = ''avg(1 - rate(node_cpu_seconds_total{mode="idle",instance="$hosts"}[1m])) by (instance)'';
          legendFormat = "{{instance}}";
        }
      ];
      title = "System Load";
      type = "gauge";
    }
  ];
  templating.list = [
    {
      definition = ''label_values(up{job="hosts"},instance)'';
      includeAll = true;
      multi = true;
      name = "hosts";
      query = {
        qryType = 1;
        query = ''label_values(up{job="hosts"},instance)'';
        refId = "PrometheusVariableQueryEditor-VariableQuery";
      };
      refresh = 1;
      skipUrlSync = false;
      sort = 0;
      type = "query";
    }
  ];
  title = "Hosts - Nix";
}
