echo 'CPU cores temperature:'
sensors | grep Core | grep  -oE '[0-9]{1,2}.[0-9]°C  ' 