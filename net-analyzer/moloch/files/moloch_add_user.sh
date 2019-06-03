#!/bin/sh

"${EROOT}/usr/bin/node" "${EROOT}/usr/lib/moloch/viewer/addUser.js" -c "${EROOT}/etc/moloch/config.ini" "$@"
