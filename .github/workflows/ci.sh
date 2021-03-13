#!/bin/sh

status=0
if grep -F abnormal /var/log/setup.log; then
  echo -e '\e[31mERROR\e[0m Abnormal termination of a script detected'
  echo -e '      Check /var/log/setup.log'
  status=1
fi
if sed -e '1,/cygsympathy/d;/running:/,$d' /var/log/setup.log.full | grep ERROR; then
  echo -e '\e[31mERROR\e[0m cygsympathy errors detected'
  echo -e '      Check /var/log/setup.log.full'
  status=1
fi
exit $status
