Combined hardware identification databases
==========================================

This repository contain a specially re-packaged copy of the pci.ids
and usb.ids files, as well as a copy of IEEE's oui.txt file

The two IDs databases are maintained by Martin Mares and Michal Vaner
(pci.ids) and Stephen J. Gowdy (usb.ids) through the help of
volunteers who can submit them to the two submission web applications:

 * [pci.ids](http://pci-ids.ucw.cz/)
 * [usb.ids](https://usb-ids.gowdy.us/index.html)

The OUI database is an officially maintained index by IEEE, and can be
accessed at https://standards.ieee.org/develop/regauth/oui/public.html .

The reason to repackage the files together is to make it simpler for
applications to require them, without having to bring in either
pciutils or usbutils, that might be unnecessary for most installs.

Updates
-------

The hwids tarball is updated generally on the weekends, and tagged if
there are new files available. You can download the tags in form of
tarballs directly from [the GitHub
repository](https://github.com/gentoo/hwids).

License
-------

The pci.ids and usb.ids files are both released under dual-license,
and you can choose which one to apply to your needs. The options are
either the GNU General Public License, version 2 or later (which
you'll find in the archive, in the file named gpl-2.0.txt), or the
3-clause BSD license that follows:

> Redistribution and use in source and binary forms, with or without
> modification, are permitted provided that the following conditions are met:
>     * Redistributions of source code must retain the above copyright
>       notice, this list of conditions and the following disclaimer.
>     * Redistributions in binary form must reproduce the above copyright
>       notice, this list of conditions and the following disclaimer in the
>       documentation and/or other materials provided with the distribution.
>     * Neither the name of the <organization> nor the
>       names of its contributors may be used to endorse or promote products
>       derived from this software without specific prior written permission.
>
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
> ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
> WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
> DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
> (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
> LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
> ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The OUI database is not officially licensed by IEEE, but should be
possible to consider it as freely distributable, as a collection of
facts.
