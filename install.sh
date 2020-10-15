#!/bin/sh -e
####################################################################################################
# Copyright (c) 2020 David Allsopp Ltd.                                                            #
# Distributed under clauses 1 and 3 of BSD-3-Clause, see terms at the end of this file.            #
####################################################################################################

dest=/usr/lib/cygsympathy

install -d "$dest"
install -T -m 755 cygsympathy.sh "$dest/cygsympathy"
install -t cygsympathy.cmd "$dest"
ln -sfT "$dest/cygsympathy" /etc/postinstall/zp_cygsympathy.sh

####################################################################################################
# Copyright (c) 2020 David Allsopp Ltd.                                                            #
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