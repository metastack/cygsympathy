# escape=`

FROM mcr.microsoft.com/windows/nanoserver:1809 AS CygSymPathy

USER ContainerAdministrator

ADD cygsympathy.cmd C:\cygwin64\lib\cygsympathy\
ADD cygsympathy.sh C:\cygwin64\lib\cygsympathy\cygsympathy
ADD .github/workflows/ci.sh C:\cygwin64\

RUN md C:\cygwin64\etc\postinstall
RUN mklink C:\cygwin64\etc\postinstall\zp_cygsympathy.sh C:\cygwin64\lib\cygsympathy\cygsympathy

ADD https://www.cygwin.com/setup-x86_64.exe C:\cygwin64\

FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS Cygwin

USER ContainerAdministrator

COPY --from=CygSymPathy C:\cygwin64 C:\cygwin64

RUN C:\cygwin64\setup-x86_64.exe `
      --quiet-mode `
      --no-shortcuts `
      --no-startmenu `
      --no-desktop `
      --only-site `
      --root C:\cygwin64 `
      --site http://mirrors.kernel.org/sourceware/cygwin/ `
      --local-package-dir C:\cygwin64\cache

RUN C:\cygwin64\bin\bash.exe -lc "/ci.sh"

ENTRYPOINT ["cmd.exe"]
