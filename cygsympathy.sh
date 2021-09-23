#!/bin/sh -e
####################################################################################################
# Copyright (c) 2020, 2021 David Allsopp Ltd.                                                      #
# Distributed under clauses 1 and 3 of BSD-3-Clause, see terms at the end of this file.            #
####################################################################################################

# CygSymPathy main script created 14-Oct-2020

cd "$(dirname "$(realpath "$0")")"

symlink ()
{
  if [ "${1#/}" != "$1" ] || [ "${1#~}" != "$1" ] ; then
    # Absolute path - ln should be fine
    CYGWIN='winsymlinks:native' ln -sfT "$1" "$2"
  else
    # Relative target - assume Cygwin will mangle the link
    target_dir=$(dirname "$2")
    if [ -d "$target_dir/$1" ] ; then
      flag='/D'
    else
      flag=''
    fi
    pwd=$(pwd)
    cd "$target_dir"
    cmd /c mklink $flag "$(basename "$2")" "$(echo "$1" | sed -e 's|/|\\|g')" > /dev/null
    cd "$pwd"
  fi
}

report ()
{
  if [ "$1" != "$3" ] || [ "$2" != "$4" ] ; then
    with_note=" with $3 -> $4"
  else
    with_note=''
  fi
  echo "Re-created $1 -> $2$with_note$5"
}

error_cookie='/tmp/cygsympathy-errors'
rm -f "$error_cookie"
cmd /c cygsympathy.cmd "$(cygpath -w /)" | tr -d '\r' | while IFS= read -r entry ; do
  type=${entry%%:*}
  entry="${entry#*:}"
  cygwin_entry="$(cygpath "$entry")"

  target=$(readlink "$cygwin_entry")
  if [ -x "$target" ] && [ "$target" != 'exe' ] && [ "${target##*.}" != 'exe' ] && cmd /c cygsympathy.cmd :lnk "$(cygpath -wa "$target")" ; then
    actual_target="$target.exe"
  else
    actual_target="$target"
  fi

  # Determine if the symlink should end .exe (assuming it ends up as a native symlink)
  final_entry="$cygwin_entry"
  if [ "$type" = 'lnk' ] ; then
    final_entry="${final_entry%.lnk}"
  fi
  if [ "$target" != 'exe' ] && [ "${target##*.}" = 'exe' ] ; then
    # Target is an executable
    if [ "$type" = 'lnk' ] ; then
      raw_entry="${entry%.lnk}"
    else
      raw_entry="${entry}"
    fi
    if [ "$raw_entry" = 'exe' ] || [ "${raw_entry##*.}" != 'exe' ] ; then
      # This isn't actually done until later because this might still be a system file
      final_entry="$final_entry.exe"
    fi
  fi

  if [ "$type" = "lnk" ] && ! cmd /c cygsympathy.cmd :lnk "$raw_entry" ; then
    echo "Cannot process $entry since $raw_entry also exists"
  else
    # /proc/cygdrive can't be represented as a native symbolic link, but if we're using native
    # symbolic links, it's perfectly safe to represent it using the mount point. cygdrive has to
    # to be mounted somewhere, we use cygpath to find it.
    case "$target" in
      /proc/cygdrive/*)
        path="${target#/proc/cygdrive/}"
        letter="${path%%/*}"
        path="${path#*/}"
        if [ "$path" = "$letter" ] ; then
          path=''
        fi
        actual_target="$(cygpath "$letter:")"
        actual_target="${actual_target%%/}/$path"
    esac

    test_link=false
    case "$actual_target" in
      /proc/*)
        if [ "$type" != 'cookie' ] ; then
          # No value in adding .exe for a cookie based entry
          actual_target="$target"
          rm -f "$cygwin_entry"
          echo -n '!<symlink>' > "$final_entry"
          echo -ne "$actual_target\\000" | uconv -t UTF16LE --add-signature >> "$final_entry"
          chattr -f +s "$final_entry"
          test_link=true
          report "$cygwin_entry" "$target" "$final_entry" "$actual_target" ' via cookie'
        fi;;
      *)
        if [ "$type" = 'symlink' ] ; then
          if [ "$target" != "$actual_target" ] ; then
            if [ "$final_entry" != "$cygwin_entry" ] ; then
              rm -f "$cygwin_entry"
            fi
            symlink "$actual_target" "$final_entry"
            test_link=true
            report "$cygwin_entry" "$target" "$final_entry" "$actual_target"
          elif [ "$final_entry" != "$cygwin_entry" ] ; then
            mv "$cygwin_entry" "$final_entry"
            echo "Renamed $cygwin_entry to $final_entry"
          fi
        else
          rm -f "$cygwin_entry"
          symlink "$actual_target" "$final_entry"
          test_link=true
          report "$cygwin_entry" "$target" "$final_entry" "$actual_target"
        fi;;
    esac

    if $test_link ; then
      content="$(readlink "$final_entry")"
      if [ "$content" != "$actual_target" ] ; then
        echo "ERROR: $final_entry is expected to point to $actual_target but the link returns $content"
        touch "$error_cookie"
      fi
    fi
  fi
done

if [ -e "$error_cookie" ] ; then
  rm -f "$error_cookie"
  status=1
else
  status=0
fi
exit $status

####################################################################################################
# Copyright (c) 2020, 2021 David Allsopp Ltd.                                                      #
#                                                                                                  #
# Redistribution and use in source and binary forms, with or without modification, are permitted   #
# provided that the following two conditions are met:                                              #
#     1. Redistributions of source code must retain the above copyright notice, this list of       #
#        conditions and the following disclaimer.                                                  #
#     2. Neither the name of David Allsopp Ltd. nor the names of its contributors may be used to   #
#        endorse or promote products derived from this software without specific prior written     #
#        permission.                                                                               #
#                                                                                                  #
# This software is provided by the Copyright Holder 'as is' and any express or implied warranties  #
# including, but not limited to, the implied warranties of merchantability and fitness for a       #
# particular purpose are disclaimed. In no event shall the Copyright Holder be liable for any      #
# direct, indirect, incidental, special, exemplary, or consequential damages (including, but not   #
# limited to, procurement of substitute goods or services; loss of use, data, or profits; or       #
# business interruption) however caused and on any theory of liability, whether in contract,       #
# strict liability, or tort (including negligence or otherwise) arising in any way out of the use  #
# of this software, even if advised of the possibility of such damage.                             #
####################################################################################################
