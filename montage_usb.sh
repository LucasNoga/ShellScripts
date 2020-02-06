#!/bin/bash
# ==> usb.sh : Monter des périphériques de stockage USB

# ==> Script pour monter et installer les périphériques de stockage d'une clé USB.
# ==> Lancer en tant que root au démarrage du système (voir ci-dessous).
# ==>
# ==> Les nouvelles distributions Linux (2004 ou ultérieures) détectent
# ==> automatiquement et installent les clés USB.
# ==> Elles n'ont donc pas besoin de ce script.
# ==> Mais c'est toujours instructif.

#  This code is free software covered by GNU GPL license version 2 or above.
#  Please refer to http://www.gnu.org/ for the full license text.
#
#  Ce code est un logiciel libre couvert par la licence GNU GPL version 2 et
#+ ultérieure. Référez-vous à http://www.gnu.org/ pour le texte complet.
#
#  Une partie du code provient de usb-mount écrit par Michael Hamilton (LGPL)
#+ voir http://users.actrix.co.nz/michael/usbmount.html
#
#  INSTALLATION
#  ------------
#  Placez ceci dans /etc/hotplug/usb/clefusb.
#  Puis regardez dans /etc/hotplug/usb.distmap, copiez toutes les entrées de
#+ stockage USB dans /etc/hotplug/usb.usermap, en substituant "usb-storage" par
#+ "diskonkey".
#  Sinon, ce code est seulement lancé lors de l'appel/suppression du module du
#+ noyau (au moins lors de mes tests), ce qui annule le but.
#
#  A FAIRE
#  -------
#  Gère plus d'un périphérique "diskonkey" en même temps (c'est-à-dire
#+ /dev/diskonkey1 et /mnt/clefusb1), etc. Le plus gros problème ici concerne
#+ la gestion par devlabel, que je n'ai pas essayé.
#

PERIPH_LIENSYMBOLIQUE=/dev/diskonkey
POINT_MONTAGE=/mnt/clefusb
LABEL_PERIPH=/sbin/devlabel
CONFIG_LABEL_PERIPH=/etc/sysconfig/devlabel
JE_SUIS=$0

##
# Fonctions pratiquement récupérées du code d'usb-mount.
#
function tousUsbScsiAttaches {
    find /proc/scsi/ -path '/proc/scsi/usb-storage*' -type f |
    xargs grep -l 'Attaché: Oui'
}
function periphScsiAPartirScsiUsb {
    echo $1 | awk -F"[-/]" '{ n=$(NF-1);
    print "/dev/sd" substr("abcdefghijklmnopqrstuvwxyz", n+1, 1) }'
}

if [ "${ACTION}" = "add" ] && [ -f "${DEVICE}" ]; then
    ##
    # Récupéré du code d'usbcam.
    #
    if [ -f /var/run/console.lock ]; then
        PROPRIETAIRE_CONSOLE=`cat /var/run/console.lock`
    elif [ -f /var/lock/console.lock ]; then
        PROPRIETAIRE_CONSOLE=`cat /var/lock/console.lock`
    else
        PROPRIETAIRE_CONSOLE=
    fi
    for entreeProc in $(tousUsbScsiAttaches); do
        scsiDev=$(periphScsiAPartirScsiUsb $entreeProc)
        #  Quelques bogues avec usb-storage?
        #  Les partitions ne sont pas dans /proc/partitions jusqu'à ce qu'elles
        #+ soient utilisées.
        /sbin/fdisk -l $scsiDev >/dev/null
        ##
        #  La plupart des périphériques ont des informations de partitionnement,
        #+ donc les données sont sur /dev/sd?1. Néanmois, quelques-uns plus
        #+ stupides n'ont pas du tout de partitions et utilisent le périphérique
        #+ complet pour du stockage de données. Il essaie de deviner si vous
        #+ avez un /dev/sd?1 et si non, il utilise le périphérique entier.
        #
        if grep -q `basename $scsiDev`1 /proc/partitions; then
            part="$scsiDev""1"
        else
            part=$scsiDev
        fi
        ##
        #  Modifie le propriétaire de la partition par l'utilisateur de la
        #+ console pour qu'ils puissent le monter.
        #
        if [ ! -z "$PROPRIETAIRE_CONSOLE" ]; then
            chown $PROPRIETAIRE_CONSOLE:disk $part
        fi
        ##
        # Ceci vérifie si nous avons déjà cet UID défini avec devlabel. Sinon,
        # il ajoute alors le périphérique à la liste.
        #
        prodid=`$LABEL_PERIPH printid -d $part`
        if ! grep -q $prodid $CONFIG_LABEL_PERIPH; then
                # croisez les doigts et espérez que cela fonctionne
            $LABEL_PERIPH add -d $part -s $PERIPH_LIENSYMBOLIQUE 2>/dev/null
        fi
        ##
        # Vérifie si le point de montage existe et le crée dans le cas contraire.
        #
        if [ ! -e $POINT_MONTAGE ]; then
            mkdir -p $POINT_MONTAGE
        fi
        ##
        # S'occupe de /etc/fstab pour faciliter le montage.
        #
        if ! grep -q "^$PERIPH_LIENSYMBOLIQUE" /etc/fstab; then
            # Ajoute une entrée fstab
            echo -e \
                "$PERIPH_LIENSYMBOLIQUE\t\t$POINT_MONTAGE\t\tauto\tnoauto,owner,kudzu 0 0" \
                >> /etc/fstab
        fi
    done
    if [ ! -z "$REMOVER" ]; then
        ##
        #  Assurez-vous que ce script est appelé lors de la suppression du
        #+ périphérique.
        #
        mkdir -p `dirname $REMOVER`
        ln -s $JE_SUIS $REMOVER
    fi
elif [ "${ACTION}" = "remove" ]; then
    ##
    # Si le périphérique est monté, le démonte proprement.
    #
    if grep -q "$POINT_MONTAGE" /etc/mtab; then
        # Démonte proprement.
        umount -l $POINT_MONTAGE
    fi
    ##
    # Le supprime à partir de /etc/fstab s'il existe.
    #
    if grep -q "^$PERIPH_LIENSYMBOLIQUE" /etc/fstab; then
        grep -v "^$PERIPH_LIENSYMBOLIQUE" /etc/fstab > /etc/.fstab.new
        mv -f /etc/.fstab.new /etc/fstab
    fi
fi

exit 0

