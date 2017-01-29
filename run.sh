#!/bin/bash

#===========================================================
# Deklarasjon av variable + evt. debug
#===========================================================

[[ -n "$DEBUG" ]] && set -x # turn -x on if DEBUG is set to a non-empty string
[[ -n "$NOEXEC" ]] && set -n # turn -n on if NOEXEC is set to a non-empty string
#set -o nounset # Feiler hvis man prøver å bruke en uinitialisert variabel
#set -o errexit # Avslutter umiddelbart hvis et statement returnerer false


#===========================================================
# Deklarasjon av funksjoner
#===========================================================


Fail() {
    echo "$1"
    exit 1
}

Usage() {
    echo "SYNOPSIS"
    echo "    $(basename $0)"

    echo
    echo "PARAMETRE"
    echo "    Ingen"
    echo
    echo "BRUK"
    echo "    Henter km-stand fra vår Model S hos Tesla, appender den til en loggfil lagret i Amazon S3."
}


#===========================================================
# Hovedprogram
#===========================================================

# cd to the directory of this script
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

TEMPFILE_LOG=$(mktemp)
TEMPFILE_OUTPUT=$(mktemp)

TESLA_EMAIL=$(grep tesla_username ~/.mytesla.conf | cut -d= -f2-)
[[ -z "$TESLA_EMAIL" ]] && Fail "Fant ikke verdi for tesla_email i ~/mytesla.conf. Avslutter."

TESLA_PASSWORD=$(grep tesla_password ~/.mytesla.conf | cut -d= -f2-)
[[ -z "$TESLA_PASSWORD" ]] && Fail "Fant ikke verdi for tesla_password i ~/.mytesla.conf. Avslutter."
export TESLA_EMAIL TESLA_PASSWORD

python ./mytesla.py > $TEMPFILE_OUTPUT || Fail "Kjøring av mytesla.py feilet. Avslutter."

./aws get ogk/mytesla/kmstand.log $TEMPFILE_LOG || Fail "Henting av kmstand-logg fra AWS feilet. Avslutter."
cat $TEMPFILE_OUTPUT >> $TEMPFILE_LOG
./aws put ogk/mytesla/kmstand.log $TEMPFILE_LOG || Fail "Skriving av kmstand-logg til AWS feilet. Avslutter."

rm $TEMPFILE_LOG $TEMPFILE_OUTPUT
