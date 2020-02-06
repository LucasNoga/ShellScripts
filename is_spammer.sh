 Exemple A.30. 

#!/bin/sh

# $Id: is_spammer.bash : Identification d'un spammer

# L'information ci-dessus est l'ID RCS.
# La dernière version de ce script est disponible sur http://www.morethan.org.

#######################################################
# Documentation
# Voir aussi "Quickstart" à la fin du script.
#######################################################

:"<<-'__is_spammer_Doc_'

    Copyright (c) Michael S. Zick, 2004
    Licence : Ré-utilisation non restreinte quelque soit la forme et
              le but
    Garantie: Aucune -{C'est un script; l'utilisateur est seul responsable.}-

Impatient?
    Code de l'application : Allez à "# # #  Code 'Chez le spammeur'  # # #"
    Sortie d'exemple      : is_spammer_outputs'"
    Comment l'utiliser    : Entrer le nom du script sans arguments.
                Ou allez à \"Quickstart\" à la fin du script.

Fournit
    Avec un nom de domaine ou une adresse IP(v4) en entrée :

    Lance un ensemble exhaustif de requêtes pour trouver les ressources réseau
    associées (raccourci pour un parcours récursif dans les TLD).

    Vérifie les adresses IP(v4) disponibles sur les serveurs de noms Blacklist.

    S'il se trouve faire partie d'une adresse IP(v4) indiquée, rapporte les
    enregistrements texte de la liste noire.
    (habituellement des liens hypertextes vers le rapport spécifique.)

Requiert
    Une connexion Internet fonctionnelle.
    (Exercice : ajoutez la vérification et/ou annulez l'opération si la
    connexion n'est pas établie lors du lancement du script.)
    Une version de Bash disposant des tableaux (2.05b+).

    Le programme externe 'dig' --
    ou outil fourni avec l'ensemble de programmes 'bind'.
    Spécifiquement, la version qui fait partie de Bind série 9.x
    Voir : http://www.isc.org

    Toutes les utilisations de 'dig' sont limitées à des fonctions d'emballage,
    qui pourraient être ré-écrites si nécessaire.
    Voir : dig_wrappers.bash pour plus de détails.
         (Documentation supplémentaire -- ci-dessous)

Usage
    Ce script requiert un seul argument, qui pourrait être:
    1) Un nom de domaine ;
    2) Une adresse IP(v4) ;
    3) Un nom de fichier, avec un nom ou une adresse par ligne.

    Ce script accepte un deuxième argument optionnel, qui pourrait être:
    1) Un serveur de noms Blacklist ;
    2) Un nom de fichier avec un serveur de noms Blacklist par ligne.

    Si le second argument n'est pas fourni, le script utilise un ensemble
    intégré de serveurs Blacklist (libres).

    Voir aussi la section Quickstart à la fin de ce script (après 'exit').

Codes de retour
    0 - Tout est OK
    1 - Échec du script
    2 - Quelque chose fait partie de la liste noire

Variables d'environnement optionnelles
    SPAMMER_TRACE
        S'il comprend le nom d'un fichier sur lequel le script a droit
        d'écriture, le script tracera toute l'exécution.

    SPAMMER_DATA
        S'il comprend le nom d'un fichier sur lequel le script a droit
        d'écriture, le script y enregitrera les données trouvées sous la forme
        d'un fichier GraphViz.
        Voir : http://www.research.att.com/sw/tools/graphviz

    SPAMMER_LIMIT
        Limite la profondeur des recherches de ressources.

        Par défaut à deux niveaux.

        Un paramètrage de 0 (zero) signifie 'illimité' . . .
          Attention : le script pourrait parcourir tout Internet !

        Une limite de 1 ou 2 est plus utile dans le cas d'un fichier de noms de
        domaine et d'adresses.
        Une limite encore plus haute est utile pour chasser les gangs de spam.


Documentation supplémentaire
    Téléchargez l'ensemble archivé de scripts expliquant et illustrant la
    fonction contenue dans ce script.
    http://personal.riverusers.com/mszick_clf.tar.bz2


Notes d'étude
    Ce script utilise un grand nombre de fonctions.
    Pratiquement toutes les fonctions générales ont leur propre script
    d'exemple. Chacun des scripts d'exemples ont leur commentaires (niveau
    tutoriel).

Projets pour ce script
    Ajoutez le support des adresses IP(v6).
    Les adresses IP(v6) sont reconnues mais pas gérées.

Projet avancé
    Ajoutez le détail de la recherche inverse dans les informations découvertes.

    Rapportez la chaîne de délégation et les contacts d'abus.

    Modifiez la sortie du fichier GraphViz pour inclure les informations
    nouvellement découvertes.

__is_spammer_Doc_

#######################################################"




#### Configuration spéciale pour l'IFS utilisée pour l'analyse des chaînes. ####

# Espace blanc == :Espace:Tabulation:Retour à la ligne:Retour chariot:
WSP_IFS=$'\x20'$'\x09'$'\x0A'$'\x0D'

# Pas d'espace blanc == Retour à la ligne:Retour chariot
NO_WSP=$'\x0A'$'\x0D'

# Séparateur de champ pour les adresses IP décimales
ADR_IFS=${NO_WSP}'.'

# Tableau de conversions de chaînes
DOT_IFS='.'${WSP_IFS}

# # # Machine à pile pour les opérations restantes # # #
# Cet ensemble de fonctions est décrite dans func_stack.bash.
# (Voir "Documentation supplémentaire" ci-dessus.)
# # #

# Pile globale des opérations restantes.
declare -f -a _pending_
# Sentinelle gloable pour les épuiseurs de pile
declare -i _p_ctrl_
# Déteneur global pour la fonction en cours d'exécution
declare -f _pend_current_

# # # Version de déboguage seulement - à supprimer pour une utilisation normale
# # #
#
# La fonction stockée dans _pend_hook_ est appellée immédiatement avant que
# chaque fonction en cours ne soit évaluée. Pile propre, _pend_current_ configuré.
#
# Ceci est démontré dans pend_hook.bash.
declare -f _pend_hook_
# # #

# La fonction ne faisant rien.
pend_dummy() { : ; }

# Efface et initialise la pile des fonctions.
pend_init() {
    unset _pending_[@]
    pend_func pend_stop_mark
    _pend_hook_='pend_dummy'  # Débogage seulement.
}

# Désactive la fonction du haut de la pile.
pend_pop() {
    if [ ${#_pending_[@]} -gt 0 ]
    then
        local -i _top_
        _top_=${#_pending_[@]}-1
        unset _pending_[$_top_]
    fi
}

# pend_func function_name [$(printf '%q\n' arguments)]
pend_func() {
    local IFS=${NO_WSP}
    set -f
    _pending_[${#_pending_[@]}]=$@
    set +f
}

# La fonction qui arrête la sortie :
pend_stop_mark() {
    _p_ctrl_=0
}

pend_mark() {
    pend_func pend_stop_mark
}

# Exécute les fonctions jusqu'à 'pend_stop_mark' . . .
pend_release() {
    local -i _top_             # Déclare _top_ en tant qu'entier.
    _p_ctrl_=${#_pending_[@]}
    while [ ${_p_ctrl_} -gt 0 ]
    do
       _top_=${#_pending_[@]}-1
       _pend_current_=${_pending_[$_top_]}
       unset _pending_[$_top_]
       $_pend_hook_            # Débogage seulement.
       eval $_pend_current_
    done
}

# Supprime les fonctions jusqu'à 'pend_stop_mark' . . .
pend_drop() {
    local -i _top_
    local _pd_ctrl_=${#_pending_[@]}
    while [ ${_pd_ctrl_} -gt 0 ]
    do
       _top_=$_pd_ctrl_-1
       if [ "${_pending_[$_top_]}" == 'pend_stop_mark' ]
       then
           unset _pending_[$_top_]
           break
       else
           unset _pending_[$_top_]
           _pd_ctrl_=$_top_
       fi
    done
    if [ ${#_pending_[@]} -eq 0 ]
    then
        pend_func pend_stop_mark
    fi
}

#### Éditeurs de tableaux ####

# Cette fonction est décrite dans edit_exact.bash.
# (Voir "Additional documentation", ci-dessus.)
# edit_exact &lt;excludes_array_name&gt; &lt;target_array_name&gt;
edit_exact() {
    [ $# -eq 2 ] ||
    [ $# -eq 3 ] || return 1
    local -a _ee_Excludes
    local -a _ee_Target
    local _ee_x
    local _ee_t
    local IFS=${NO_WSP}
    set -f
    eval _ee_Excludes=\( \$\{$1\[@\]\} \)
    eval _ee_Target=\( \$\{$2\[@\]\} \)
    local _ee_len=${#_ee_Target[@]}     # Longueur originale.
    local _ee_cnt=${#_ee_Excludes[@]}   # Exclut la longueur de la liste.
    [ ${_ee_len} -ne 0 ] || return 0    # Ne peut pas éditer une longueur nulle.
    [ ${_ee_cnt} -ne 0 ] || return 0    # Ne peut pas éditer une longueur nulle.
    for (( x = 0; x < ${_ee_cnt} ; x++ ))
    do
        _ee_x=${_ee_Excludes[$x]}
        for (( n = 0 ; n < ${_ee_len} ; n++ ))
        do
            _ee_t=${_ee_Target[$n]}
            if [ x"${_ee_t}" == x"${_ee_x}" ]
            then
                unset _ee_Target[$n]     # Désactive la correspondance.
                [ $# -eq 2 ] && break    # Si deux arguments, alors terminé.
            fi
        done
    done
    eval $2=\( \$\{_ee_Target\[@\]\} \)
    set +f
    return 0
}

# Cette fonction est décrite dans edit_by_glob.bash.
# edit_by_glob &lt;excludes_array_name&gt; &lt;target_array_name&gt;
edit_by_glob() {
    [ $# -eq 2 ] ||
    [ $# -eq 3 ] || return 1
    local -a _ebg_Excludes
    local -a _ebg_Target
    local _ebg_x
    local _ebg_t
    local IFS=${NO_WSP}
    set -f
    eval _ebg_Excludes=\( \$\{$1\[@\]\} \)
    eval _ebg_Target=\( \$\{$2\[@\]\} \)
    local _ebg_len=${#_ebg_Target[@]}
    local _ebg_cnt=${#_ebg_Excludes[@]}
    [ ${_ebg_len} -ne 0 ] || return 0
    [ ${_ebg_cnt} -ne 0 ] || return 0
    for (( x = 0; x < ${_ebg_cnt} ; x++ ))
    do
        _ebg_x=${_ebg_Excludes[$x]}
        for (( n = 0 ; n < ${_ebg_len} ; n++ ))
        do
            [ $# -eq 3 ] && _ebg_x=${_ebg_x}'*'  #  Do prefix edit
            if [ ${_ebg_Target[$n]:=} ]          #+ if defined & set.
            then
                _ebg_t=${_ebg_Target[$n]/#${_ebg_x}/}
                [ ${#_ebg_t} -eq 0 ] && unset _ebg_Target[$n]
            fi
        done
    done
    eval $2=\( \$\{_ebg_Target\[@\]\} \)
    set +f
    return 0
}

# Cette fonction est décrite par unique_lines.bash.
# unique_lines &lt;in_name&gt; &lt;out_name&gt;
unique_lines() {
    [ $# -eq 2 ] || return 1
    local -a _ul_in
    local -a _ul_out
    local -i _ul_cnt
    local -i _ul_pos
    local _ul_tmp
    local IFS=${NO_WSP}
    set -f
    eval _ul_in=\( \$\{$1\[@\]\} \)
    _ul_cnt=${#_ul_in[@]}
    for (( _ul_pos = 0 ; _ul_pos < ${_ul_cnt} ; _ul_pos++ ))
    do
        if [ ${_ul_in[${_ul_pos}]:=} ]      # Si définie et non vide
        then
            _ul_tmp=${_ul_in[${_ul_pos}]}
            _ul_out[${#_ul_out[@]}]=${_ul_tmp}
            for (( zap = _ul_pos ; zap < ${_ul_cnt} ; zap++ ))
            do
                [ ${_ul_in[${zap}]:=} ] &&
                [ 'x'${_ul_in[${zap}]} == 'x'${_ul_tmp} ] &&
                    unset _ul_in[${zap}]
            done
        fi
    done
    eval $2=\( \$\{_ul_out\[@\]\} \)
    set +f
    return 0
}

# Cette fonction est décrite par char_convert.bash.
# to_lower &lt;string&gt;
to_lower() {
    [ $# -eq 1 ] || return 1
    local _tl_out
    _tl_out=${1//A/a}
    _tl_out=${_tl_out//B/b}
    _tl_out=${_tl_out//C/c}
    _tl_out=${_tl_out//D/d}
    _tl_out=${_tl_out//E/e}
    _tl_out=${_tl_out//F/f}
    _tl_out=${_tl_out//G/g}
    _tl_out=${_tl_out//H/h}
    _tl_out=${_tl_out//I/i}
    _tl_out=${_tl_out//J/j}
    _tl_out=${_tl_out//K/k}
    _tl_out=${_tl_out//L/l}
    _tl_out=${_tl_out//M/m}
    _tl_out=${_tl_out//N/n}
    _tl_out=${_tl_out//O/o}
    _tl_out=${_tl_out//P/p}
    _tl_out=${_tl_out//Q/q}
    _tl_out=${_tl_out//R/r}
    _tl_out=${_tl_out//S/s}
    _tl_out=${_tl_out//T/t}
    _tl_out=${_tl_out//U/u}
    _tl_out=${_tl_out//V/v}
    _tl_out=${_tl_out//W/w}
    _tl_out=${_tl_out//X/x}
    _tl_out=${_tl_out//Y/y}
    _tl_out=${_tl_out//Z/z}
    echo ${_tl_out}
    return 0
}

#### Fonctions d'aide de l'application ####

# Tout le monde n'utilise pas de points comme séparateur (APNIC, par exemple).
# Cette fonction est décrite par to_dot.bash
# to_dot &lt;string&gt;
to_dot() {
    [ $# -eq 1 ] || return 1
    echo ${1//[#|@|%]/.}
    return 0
}

# Cette fonction est décrite par is_number.bash.
# is_number &lt;input&gt;
is_number() {
    [ "$#" -eq 1 ]    || return 1  # est-ce blanc ?
    [ x"$1" == 'x0' ] && return 0  # est-ce zéro  ?
    local -i tst
    let tst=$1 2>/dev/null         # sinon, c'est numérique !
    return $?
}

# Cette fonction est décrite par is_address.bash.
# is_address &lt;input&gt;
is_address() {
    [ $# -eq 1 ] || return 1    # Blanc ==> faux
    local -a _ia_input
    local IFS=${ADR_IFS}
    _ia_input=( $1 )
    if  [ ${#_ia_input[@]} -eq 4 ]  &&
        is_number ${_ia_input[0]}   &&
        is_number ${_ia_input[1]}   &&
        is_number ${_ia_input[2]}   &&
        is_number ${_ia_input[3]}   &&
        [ ${_ia_input[0]} -lt 256 ] &&
        [ ${_ia_input[1]} -lt 256 ] &&
        [ ${_ia_input[2]} -lt 256 ] &&
        [ ${_ia_input[3]} -lt 256 ]
    then
        return 0
    else
        return 1
    fi
}

# Cette fonction est décrite par split_ip.bash.
# split_ip &lt;IP_address&gt; &lt;array_name_norm&gt; [&lt;array_name_rev&gt;]
split_ip() {
    [ $# -eq 3 ] ||              #  Soit trois
    [ $# -eq 2 ] || return 1     #+ soit deux arguments
    local -a _si_input
    local IFS=${ADR_IFS}
    _si_input=( $1 )
    IFS=${WSP_IFS}
    eval $2=\(\ \$\{_si_input\[@\]\}\ \)
    if [ $# -eq 3 ]
    then
        # Construit le tableau de l'ordre des requêtes.
        local -a _dns_ip
        _dns_ip[0]=${_si_input[3]}
        _dns_ip[1]=${_si_input[2]}
        _dns_ip[2]=${_si_input[1]}
        _dns_ip[3]=${_si_input[0]}
        eval $3=\(\ \$\{_dns_ip\[@\]\}\ \)
    fi
    return 0
}

# Cette fonction est décrite par dot_array.bash.
# dot_array &lt;array_name&gt;
dot_array() {
    [ $# -eq 1 ] || return 1     # Un seul argument requis.
    local -a _da_input
    eval _da_input=\(\ \$\{$1\[@\]\}\ \)
    local IFS=${DOT_IFS}
    local _da_output=${_da_input[@]}
    IFS=${WSP_IFS}
    echo ${_da_output}
    return 0
}

# Cette fonction est décrite par file_to_array.bash
# file_to_array &lt;file_name&gt; &lt;line_array_name&gt;
file_to_array() {
    [ $# -eq 2 ] || return 1  # Deux arguments requis.
    local IFS=${NO_WSP}
    local -a _fta_tmp_
    _fta_tmp_=( $(cat $1) )
    eval $2=\( \$\{_fta_tmp_\[@\]\} \)
    return 0
}

# Columnized print of an array of multi-field strings.
# col_print &lt;array_name&gt; &lt;min_space&gt; &lt;tab_stop [tab_stops]&gt;
col_print() {
    [ $# -gt 2 ] || return 0
    local -a _cp_inp
    local -a _cp_spc
    local -a _cp_line
    local _cp_min
    local _cp_mcnt
    local _cp_pos
    local _cp_cnt
    local _cp_tab
    local -i _cp
    local -i _cpf
    local _cp_fld
    #  ATTENTION : LIGNE SUIVANTE NON BLANCHE -- CE SONT DES ESPACES ENTRE
    #+             GUILLEMET.
    local _cp_max='                                                            '
    set -f
    local IFS=${NO_WSP}
    eval _cp_inp=\(\ \$\{$1\[@\]\}\ \)
    [ ${#_cp_inp[@]} -gt 0 ] || return 0 # Le cas vide est simple.
    _cp_mcnt=$2
    _cp_min=${_cp_max:1:${_cp_mcnt}}
    shift
    shift
    _cp_cnt=$#
    for (( _cp = 0 ; _cp < _cp_cnt ; _cp++ ))
    do
        _cp_spc[${#_cp_spc[@]}]="${_cp_max:2:$1}" #"
        shift
    done
    _cp_cnt=${#_cp_inp[@]}
    for (( _cp = 0 ; _cp < _cp_cnt ; _cp++ ))
    do
        _cp_pos=1
        IFS=${NO_WSP}$'\x20'
        _cp_line=( ${_cp_inp[${_cp}]} )
        IFS=${NO_WSP}
        for (( _cpf = 0 ; _cpf < ${#_cp_line[@]} ; _cpf++ ))
        do
            _cp_tab=${_cp_spc[${_cpf}]:${_cp_pos}}
            if [ ${#_cp_tab} -lt ${_cp_mcnt} ]
            then
                _cp_tab="${_cp_min}"
            fi
            echo -n "${_cp_tab}"
            (( _cp_pos = ${_cp_pos} + ${#_cp_tab} ))
            _cp_fld="${_cp_line[${_cpf}]}"
            echo -n ${_cp_fld}
            (( _cp_pos = ${_cp_pos} + ${#_cp_fld} ))
        done
        echo
    done
    set +f
    return 0
}

# # # # Flux de données 'Chassez le spammeur' # # # #

# Code de retour de l'application
declare -i _hs_RC

# Entrée originale, à partir de laquelle les adresses IP sont supprimées
# Après cela, les noms de domaine à vérifier
declare -a uc_name

# Les adresses IP de l'entrée originale sont déplacées ici
# Après cela, les adresses IP à vérifier
declare -a uc_address

# Noms contre lesquels l'expansion d'adresses est lancée
# Prêt pour la recherche des détails des noms
declare -a chk_name

# Noms contre lesquelles l'expansion de noms est lancée
# Prêt pour la recherche des détails des adresses
declare -a chk_address

#  La récursion est depth-first-by-name.
#  expand_input_address maintient cette liste pour prohiber
#+ deux fois les adresses à rechercher durant la récursion
#+ des noms de domaine.
declare -a been_there_addr
been_there_addr=( '127.0.0.1' ) # Liste blanche pour localhost

# Noms que nous avons vérifié (ou abandonné)
declare -a known_name

# Adresses que nous avons vérifié (ou abandonné)
declare -a known_address

#  Liste de zéro ou plus de serveurs Blacklist pour la vérification.
#  Chaque 'known_address' vérifiera chaque serveur,
#+ avec des réponses négatives et des échecs supprimés.
declare -a list_server

# limite d'indirection - initialisée à zéro == pas de limite
indirect=${SPAMMER_LIMIT:=2}

# # # # données de sortie d'informations 'Chassez le
spammeur' # # # #

# Tout nom de domaine pourrait avoir de nombreuses adresses IP.
# Toute adresse IP pourrait avoir de multiples noms de domaines.
# Du coup, trace des paires uniques adresse-nom.
declare -a known_pair
declare -a reverse_pair

#  En plus des variables de flux de données ; known_address
#+ known_name et list_server, ce qui suit est sorti vers le fichier d'interface
#+ graphique externe.

# Chaîne d'autorité, parent -> champs SOA.
declare -a auth_chain

# Référence la chaîne, nom du parent -> nom du fils
declare -a ref_chain

# Chaîne DNS - nom de domaine -> adresse
declare -a name_address

# Paires de nom et service - nom de domaine -> service
declare -a name_srvc

# Paires de nom et ressource - nom de domaine -> enregistrement de ressource
declare -a name_resource

# Paires de parent et fils - nom de parent -> nom du fils
# Ceci POURRAIT NE PAS être identique au ref_chain qui suit !
declare -a parent_child

# Paires des correspondances d'adresses et des listes noires - adresse->serveur
declare -a address_hits

# Liste les données du fichier d'interface
declare -f _dot_dump
_dot_dump=pend_dummy   # Initialement un no-op

#  Les traces des données sont activées en initialisant la variable
#+ d'environnement SPAMMER_DATA avec le nom d'un fichier sur lequel le script
#+ peut écrire.
declare _dot_file

# Fonction d'aide pour la fonction dump-to-dot-file
# dump_to_dot &lt;array_name&gt; &lt;prefix&gt;
dump_to_dot() {
    local -a _dda_tmp
    local -i _dda_cnt
    local _dda_form='    '${2}'%04u %s\n'
    local IFS=${NO_WSP}
    eval _dda_tmp=\(\ \$\{$1\[@\]\}\ \)
    _dda_cnt=${#_dda_tmp[@]}
    if [ ${_dda_cnt} -gt 0 ]
    then
        for (( _dda = 0 ; _dda < _dda_cnt ; _dda++ ))
        do
            printf "${_dda_form}" \
                   "${_dda}" "${_dda_tmp[${_dda}]}" >>${_dot_file}
        done
    fi
}

# Qui initialise aussi _dot_dump par cette fonction . . .
dump_dot() {
    local -i _dd_cnt
    echo '# Data vintage: '$(date -R) >${_dot_file}
    echo '# ABS Guide: is_spammer.bash; v2, 2004-msz' >>${_dot_file}
    echo >>${_dot_file}
    echo 'digraph G {' >>${_dot_file}

    if [ ${#known_name[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known domain name nodes' >>${_dot_file}
        _dd_cnt=${#known_name[@]}
        for (( _dd = 0 ; _dd < _dd_cnt ; _dd++ ))
        do
            printf '    N%04u [label="%s"] ;\n' \
                   "${_dd}" "${known_name[${_dd}]}" >>${_dot_file}
        done
    fi

    if [ ${#known_address[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known address nodes' >>${_dot_file}
        _dd_cnt=${#known_address[@]}
        for (( _dd = 0 ; _dd < _dd_cnt ; _dd++ ))
        do
            printf '    A%04u [label="%s"] ;\n' \
                   "${_dd}" "${known_address[${_dd}]}" >>${_dot_file}
        done
    fi

    echo                                   >>${_dot_file}
    echo '/*'                              >>${_dot_file}
    echo ' * Known relationships :: User conversion to'  >>${_dot_file}
    echo ' * graphic form by hand or program required.'  >>${_dot_file}
    echo ' *'                              >>${_dot_file}

    if [ ${#auth_chain[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Authority reference edges followed and field source.'  >>${_dot_file}
        dump_to_dot auth_chain AC
    fi

    if [ ${#ref_chain[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Name reference edges followed and field source.'  >>${_dot_file}
        dump_to_dot ref_chain RC
    fi

    if [ ${#name_address[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known name->address edges' >>${_dot_file}
        dump_to_dot name_address NA
    fi

    if [ ${#name_srvc[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known name->service edges' >>${_dot_file}
        dump_to_dot name_srvc NS
    fi

    if [ ${#name_resource[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known name->resource edges' >>${_dot_file}
        dump_to_dot name_resource NR
    fi

    if [ ${#parent_child[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known parent->child edges' >>${_dot_file}
        dump_to_dot parent_child PC
    fi

    if [ ${#list_server[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known Blacklist nodes' >>${_dot_file}
        _dd_cnt=${#list_server[@]}
        for (( _dd = 0 ; _dd < _dd_cnt ; _dd++ ))
        do
            printf '    LS%04u [label="%s"] ;\n' \
                   "${_dd}" "${list_server[${_dd}]}" >>${_dot_file}
        done
    fi

    unique_lines address_hits address_hits
    if [ ${#address_hits[@]} -gt 0 ]
    then
        echo >>${_dot_file}
        echo '# Known address->Blacklist_hit edges' >>${_dot_file}
        echo '# CAUTION: dig warnings can trigger false hits.' >>${_dot_file}
        dump_to_dot address_hits AH
    fi
    echo          >>${_dot_file}
    echo ' *'     >>${_dot_file}
    echo ' * That is a lot of relationships. Happy graphing.' >>${_dot_file}
    echo ' */'    >>${_dot_file}
    echo '}'      >>${_dot_file}
    return 0
}

# # # # Flux d'exécution 'Chassez le spammeur' # # # #

#  La trace d'exécution est activée en initialisant la variable d'environnement
#+ SPAMMER_TRACE avec le nom d'un fichier sur lequel le script peut écrire.
declare -a _trace_log
declare _log_file

# Fonction pour remplir le journal de traces
trace_logger() {
    _trace_log[${#_trace_log[@]}]=${_pend_current_}
}

# Enregistre le journal des traces vers la variable fichier.
declare -f _log_dump
_log_dump=pend_dummy   # Initialement un no-op.

# Enregistre le journal des traces vers un fichier.
dump_log() {
    local -i _dl_cnt
    _dl_cnt=${#_trace_log[@]}
    for (( _dl = 0 ; _dl < _dl_cnt ; _dl++ ))
    do
        echo ${_trace_log[${_dl}]} >> ${_log_file}
    done
    _dl_cnt=${#_pending_[@]}
    if [ ${_dl_cnt} -gt 0 ]
    then
        _dl_cnt=${_dl_cnt}-1
        echo '# # # Operations stack not empty # # #' >> ${_log_file}
        for (( _dl = ${_dl_cnt} ; _dl >= 0 ; _dl-- ))
        do
            echo ${_pending_[${_dl}]} >> ${_log_file}
        done
    fi
}

# # # Emballages de l'outil 'dig' # # #
#
#  Ces emballages sont dérivées des exemples affichés dans
#+ dig_wrappers.bash.
#
#  La différence majeur est que ceux-ci retournent leur résultat comme une liste
#+ dans un tableau.
#
#  Voir dig_wrappers.bash pour les détails et utiliser ce script pour développer
#+ toute modification.
#
# # #

# Réponse courte : 'dig' analyse la réponse.

# Recherche avant :: Nom -> Adresse
# short_fwd &lt;domain_name&gt; &lt;array_name&gt;
short_fwd() {
    local -a _sf_reply
    local -i _sf_rc
    local -i _sf_cnt
    IFS=${NO_WSP}
echo -n '.'
# echo 'sfwd: '${1}
    _sf_reply=( $(dig +short ${1} -c in -t a 2>/dev/null) )
    _sf_rc=$?
    if [ ${_sf_rc} -ne 0 ]
    then
        _trace_log[${#_trace_log[@]}]='## Lookup error '${_sf_rc}' on '${1}' ##'
# [ ${_sf_rc} -ne 9 ] && pend_drop
        return ${_sf_rc}
    else
        # Quelques versions de 'dig' renvoient des avertissements sur stdout.
        _sf_cnt=${#_sf_reply[@]}
        for (( _sf = 0 ; _sf < ${_sf_cnt} ; _sf++ ))
        do
            [ 'x'${_sf_reply[${_sf}]:0:2} == 'x;;' ] &&
                unset _sf_reply[${_sf}]
        done
        eval $2=\( \$\{_sf_reply\[@\]\} \)
    fi
    return 0
}

# Recherche inverse :: Adresse -> Nom
# short_rev &lt;ip_address&gt; &lt;array_name&gt;
short_rev() {
    local -a _sr_reply
    local -i _sr_rc
    local -i _sr_cnt
    IFS=${NO_WSP}
echo -n '.'
# echo 'srev: '${1}
    _sr_reply=( $(dig +short -x ${1} 2>/dev/null) )
    _sr_rc=$?
    if [ ${_sr_rc} -ne 0 ]
    then
        _trace_log[${#_trace_log[@]}]='## Lookup error '${_sr_rc}' on '${1}'
##'
# [ ${_sr_rc} -ne 9 ] && pend_drop
        return ${_sr_rc}
    else
        # Quelques versions de 'dig' renvoient des avertissements sur stdout.
        _sr_cnt=${#_sr_reply[@]}
        for (( _sr = 0 ; _sr < ${_sr_cnt} ; _sr++ ))
        do
            [ 'x'${_sr_reply[${_sr}]:0:2} == 'x;;' ] &&
                unset _sr_reply[${_sr}]
        done
        eval $2=\( \$\{_sr_reply\[@\]\} \)
    fi
    return 0
}

#  Recherche du format spécial utilisé pour lancer des requêtes sur les serveurs
#+ de listes noires (blacklist).
# short_text &lt;ip_address&gt; &lt;array_name&gt;
short_text() {
    local -a _st_reply
    local -i _st_rc
    local -i _st_cnt
    IFS=${NO_WSP}
# echo 'stxt: '${1}
    _st_reply=( $(dig +short ${1} -c in -t txt 2>/dev/null) )
    _st_rc=$?
    if [ ${_st_rc} -ne 0 ]
    then
        _trace_log[${#_trace_log[@]}]='## Text lookup error '${_st_rc}' on '${1}' ##'
# [ ${_st_rc} -ne 9 ] && pend_drop
        return ${_st_rc}
    else
        # Quelques versions de 'dig' renvoient des avertissements sur stdout.
        _st_cnt=${#_st_reply[@]}
        for (( _st = 0 ; _st < ${#_st_cnt} ; _st++ ))
        do
            [ 'x'${_st_reply[${_st}]:0:2} == 'x;;' ] &&
                unset _st_reply[${_st}]
        done
        eval $2=\( \$\{_st_reply\[@\]\} \)
    fi
    return 0
}

# Les formes longues, aussi connues sous le nom de versions "Analyse toi-même"

# RFC 2782   Recherche de service
# dig +noall +nofail +answer _ldap._tcp.openldap.org -t srv
# _&lt;service&gt;._&lt;protocol&gt;.&lt;domain_name&gt;
# _ldap._tcp.openldap.org. 3600   IN      SRV     0 0 389 ldap.openldap.org.
# domain TTL Class SRV Priority Weight Port Target

# Recherche avant :: Nom -> transfert de zone du pauvre
# long_fwd &lt;domain_name&gt; &lt;array_name&gt;
long_fwd() {
    local -a _lf_reply
    local -i _lf_rc
    local -i _lf_cnt
    IFS=${NO_WSP}
echo -n ':'
# echo 'lfwd: '${1}
    _lf_reply=( $(
        dig +noall +nofail +answer +authority +additional \
            ${1} -t soa ${1} -t mx ${1} -t any 2>/dev/null) )
    _lf_rc=$?
    if [ ${_lf_rc} -ne 0 ]
    then
        _trace_log[${#_trace_log[@]}]='## Zone lookup error '${_lf_rc}' on
'${1}' ##'
# [ ${_lf_rc} -ne 9 ] && pend_drop
        return ${_lf_rc}
    else
        # Quelques versions de 'dig' renvoient des avertissements sur stdout.
        _lf_cnt=${#_lf_reply[@]}
        for (( _lf = 0 ; _lf < ${_lf_cnt} ; _lf++ ))
        do
            [ 'x'${_lf_reply[${_lf}]:0:2} == 'x;;' ] &&
                unset _lf_reply[${_lf}]
        done
        eval $2=\( \$\{_lf_reply\[@\]\} \)
    fi
    return 0
}
#   La recherche inverse de nom de domaine correspondant à l'adresse IPv6:
#       4321:0:1:2:3:4:567:89ab
#   pourrait donnée (en hexadécimal) :
#   b.a.9.8.7.6.5.0.4.0.0.0.3.0.0.0.2.0.0.0.1.0.0.0.0.0.0.0.1.2.3.4.IP6.ARPA.

# Recherche inverse :: Adresse -> chaîne de délégation du pauvre
# long_rev &lt;rev_ip_address&gt; &lt;array_name&gt;
long_rev() {
    local -a _lr_reply
    local -i _lr_rc
    local -i _lr_cnt
    local _lr_dns
    _lr_dns=${1}'.in-addr.arpa.'
    IFS=${NO_WSP}
echo -n ':'
# echo 'lrev: '${1}
    _lr_reply=( $(
         dig +noall +nofail +answer +authority +additional \
             ${_lr_dns} -t soa ${_lr_dns} -t any 2>/dev/null) )
    _lr_rc=$?
    if [ ${_lr_rc} -ne 0 ]
    then
        _trace_log[${#_trace_log[@]}]='## Delegation lookup error '${_lr_rc}' on '${1}' ##'
# [ ${_lr_rc} -ne 9 ] && pend_drop
        return ${_lr_rc}
    else
        # Quelques versions de 'dig' renvoient des avertissements sur stdout.
        _lr_cnt=${#_lr_reply[@]}
        for (( _lr = 0 ; _lr < ${_lr_cnt} ; _lr++ ))
        do
            [ 'x'${_lr_reply[${_lr}]:0:2} == 'x;;' ] &&
                unset _lr_reply[${_lr}]
        done
        eval $2=\( \$\{_lr_reply\[@\]\} \)
    fi
    return 0
}

## Fonctions spécifiques à l'application ##

# Récupère un nom possible ; supprime root et TLD.
# name_fixup &lt;string&gt;
name_fixup(){
    local -a _nf_tmp
    local -i _nf_end
    local _nf_str
    local IFS
    _nf_str=$(to_lower ${1})
    _nf_str=$(to_dot ${_nf_str})
    _nf_end=${#_nf_str}-1
    [ ${_nf_str:${_nf_end}} != '.' ] &&
        _nf_str=${_nf_str}'.'
    IFS=${ADR_IFS}
    _nf_tmp=( ${_nf_str} )
    IFS=${WSP_IFS}
    _nf_end=${#_nf_tmp[@]}
    case ${_nf_end} in
    0) # Pas de point, seulement des points
        echo
        return 1
    ;;
    1) # Seulement un TLD.
        echo
        return 1
    ;;
    2) # Pourrait être bon.
       echo ${_nf_str}
       return 0
       # Besoin d'une table de recherche ?
       if [ ${#_nf_tmp[1]} -eq 2 ]
       then # TLD codé suivant le pays.
           echo
           return 1
       else
           echo ${_nf_str}
           return 0
       fi
    ;;
    esac
    echo ${_nf_str}
    return 0
}

# Récupère le(s) entrée(s) originale(s).
split_input() {
    [ ${#uc_name[@]} -gt 0 ] || return 0
    local -i _si_cnt
    local -i _si_len
    local _si_str
    unique_lines uc_name uc_name
    _si_cnt=${#uc_name[@]}
    for (( _si = 0 ; _si < _si_cnt ; _si++ ))
    do
        _si_str=${uc_name[$_si]}
        if is_address ${_si_str}
        then
            uc_address[${#uc_address[@]}]=${_si_str}
            unset uc_name[$_si]
        else
            if ! uc_name[$_si]=$(name_fixup ${_si_str})
            then
                unset ucname[$_si]
            fi
        fi
    done
    uc_name=( ${uc_name[@]} )
    _si_cnt=${#uc_name[@]}
    _trace_log[${#_trace_log[@]}]='## Input '${_si_cnt}' unchecked name input(s). ##'
    _si_cnt=${#uc_address[@]}
    _trace_log[${#_trace_log[@]}]='## Input '${_si_cnt}' unchecked address input(s). ##'
    return 0
}

## Fonctions de découverte -- verrouillage récursif par des données externes ##
## Le début 'si la liste est vide; renvoyer 0' de chacun est requis. ##

# Limiteur de récursion
# limit_chk() &lt;next_level&gt;
limit_chk() {
    local -i _lc_lmt
    # Vérifiez la limite d'indirection.
    if [ ${indirect} -eq 0 ] || [ $# -eq 0 ]
    then
        # Le choix 'faites-à-chaque-fois'
        echo 1                 # Toute valeur le fera.
        return 0               # OK pour continuer.
    else
        # La limite est effective.
        if [ ${indirect} -lt ${1} ]
        then
            echo ${1}          # Quoi que ce soit.
            return 1           # Arrêter ici.
        else
            _lc_lmt=${1}+1     # Augmenter la limite donnée.
            echo ${_lc_lmt}    # L'afficher.
            return 0           # OK pour continuer.
        fi
    fi
}

# Pour chaque nom dans uc_name:
#     Déplacez le nom dans chk_name.
#     Ajoutez les adresses à uc_address.
#     Lancez expand_input_address.
#     Répétez jusqu'à ce que rien de nouveau ne soit trouvé.
# expand_input_name &lt;indirection_limit&gt;
expand_input_name() {
    [ ${#uc_name[@]} -gt 0 ] || return 0
    local -a _ein_addr
    local -a _ein_new
    local -i _ucn_cnt
    local -i _ein_cnt
    local _ein_tst
    _ucn_cnt=${#uc_name[@]}

    if  ! _ein_cnt=$(limit_chk ${1})
    then
        return 0
    fi

    for (( _ein = 0 ; _ein < _ucn_cnt ; _ein++ ))
    do
        if short_fwd ${uc_name[${_ein}]} _ein_new
        then
            for (( _ein_cnt = 0 ; _ein_cnt < ${#_ein_new[@]}; _ein_cnt++ ))
            do
                _ein_tst=${_ein_new[${_ein_cnt}]}
                if is_address ${_ein_tst}
                then
                    _ein_addr[${#_ein_addr[@]}]=${_ein_tst}
                fi
           done
        fi
    done
    unique_lines _ein_addr _ein_addr     # Scrub duplicates.
    edit_exact chk_address _ein_addr     # Scrub pending detail.
    edit_exact known_address _ein_addr   # Scrub already detailed.
    if [ ${#_ein_addr[@]} -gt 0 ]        # Anything new?
    then
        uc_address=( ${uc_address[@]} ${_ein_addr[@]} )
        pend_func expand_input_address ${1}
        _trace_log[${#_trace_log[@]}]='## Added '${#_ein_addr[@]}' unchecked address input(s). ##'
    fi
    edit_exact chk_name uc_name          # Scrub pending detail.
    edit_exact known_name uc_name        # Scrub already detailed.
    if [ ${#uc_name[@]} -gt 0 ]
    then
        chk_name=( ${chk_name[@]} ${uc_name[@]}  )
        pend_func detail_each_name ${1}
    fi
    unset uc_name[@]
    return 0
}

# Pour chaque adresse dans uc_address:
#     Déplacez l'adresse vers chk_address.
#     Ajoutez les noms à uc_name.
#     Lancez expand_input_name.
#     Répétez jusqu'à ce que rien de nouveau ne soit trouvé.
# expand_input_address &lt;indirection_limit&gt;
expand_input_address() {
    [ ${#uc_address[@]} -gt 0 ] || return 0
    local -a _eia_addr
    local -a _eia_name
    local -a _eia_new
    local -i _uca_cnt
    local -i _eia_cnt
    local _eia_tst
    unique_lines uc_address _eia_addr
    unset uc_address[@]
    edit_exact been_there_addr _eia_addr
    _uca_cnt=${#_eia_addr[@]}
    [ ${_uca_cnt} -gt 0 ] &&
        been_there_addr=( ${been_there_addr[@]} ${_eia_addr[@]} )

    for (( _eia = 0 ; _eia < _uca_cnt ; _eia++ ))
    do
            if short_rev ${_eia_addr[${_eia}]} _eia_new
            then
                for (( _eia_cnt = 0 ; _eia_cnt < ${#_eia_new[@]} ; _eia_cnt++ ))
                do
                    _eia_tst=${_eia_new[${_eia_cnt}]}
                    if _eia_tst=$(name_fixup ${_eia_tst})
                    then
                        _eia_name[${#_eia_name[@]}]=${_eia_tst}
                    fi
                done
            fi
    done
    unique_lines _eia_name _eia_name     # Scrub duplicates.
    edit_exact chk_name _eia_name        # Scrub pending detail.
    edit_exact known_name _eia_name      # Scrub already detailed.
    if [ ${#_eia_name[@]} -gt 0 ]        # Anything new?
    then
        uc_name=( ${uc_name[@]} ${_eia_name[@]} )
        pend_func expand_input_name ${1}
        _trace_log[${#_trace_log[@]}]='## Added '${#_eia_name[@]}' unchecked name input(s). ##'
    fi
    edit_exact chk_address _eia_addr     # Scrub pending detail.
    edit_exact known_address _eia_addr   # Scrub already detailed.
    if [ ${#_eia_addr[@]} -gt 0 ]        # Anything new?
    then
        chk_address=( ${chk_address[@]} ${_eia_addr[@]} )
        pend_func detail_each_address ${1}
    fi
    return 0
}

# La réponse de la zone analysez-le-vous-même.
# L'entrée est la liste chk_name.
# detail_each_name &lt;indirection_limit&gt;
detail_each_name() {
    [ ${#chk_name[@]} -gt 0 ] || return 0
    local -a _den_chk       # Noms à vérifier
    local -a _den_name      # Noms trouvés ici
    local -a _den_address   # Adresses trouvées ici
    local -a _den_pair      # Paires trouvés ici
    local -a _den_rev       # Paires inverses trouvées ici
    local -a _den_tmp       # Ligne en cours d'analyse
    local -a _den_auth      # Contact SOA en cours d'analyse
    local -a _den_new       # La réponse de la zone
    local -a _den_pc        # Parent-Fils devient très rapide
    local -a _den_ref       # Ainsi que la chaîne de référence
    local -a _den_nr        # Nom-Ressource peut être gros
    local -a _den_na        # Nom-Adresse
    local -a _den_ns        # Nom-Service
    local -a _den_achn      # Chaîne d'autorité
    local -i _den_cnt       # Nombre de noms à détailler
    local -i _den_lmt       # Limite d'indirection
    local _den_who          # Named en cours d'exécution
    local _den_rec          # Type d'enregistrement en cours d'exécution
    local _den_cont         # Domaine du contact
    local _den_str          # Correction du nom
    local _den_str2         # Correction inverse
    local IFS=${WSP_IFS}

    # Copie locale, unique de noms à vérifier
    unique_lines chk_name _den_chk
    unset chk_name[@]       # Fait avec des globales.

    # Moins de noms déjà connus
    edit_exact known_name _den_chk
    _den_cnt=${#_den_chk[@]}

    # S'il reste quelque chose, ajoutez à known_name.
    [ ${_den_cnt} -gt 0 ] &&
        known_name=( ${known_name[@]} ${_den_chk[@]} )

    # pour la liste des (précédents) noms inconnus . . .
    for (( _den = 0 ; _den < _den_cnt ; _den++ ))
    do
        _den_who=${_den_chk[${_den}]}
        if long_fwd ${_den_who} _den_new
        then
            unique_lines _den_new _den_new
            if [ ${#_den_new[@]} -eq 0 ]
            then
                _den_pair[${#_den_pair[@]}]='0.0.0.0 '${_den_who}
            fi

            # Analyser chaque ligne de la réponse.
            for (( _line = 0 ; _line < ${#_den_new[@]} ; _line++ ))
            do
                IFS=${NO_WSP}$'\x09'$'\x20'
                _den_tmp=( ${_den_new[${_line}]} )
                IFS=${WSP_IFS}
                #  Si l'enregistrement est utilisable et n'est pas un message
                #+ d'avertissement . . .
                if [ ${#_den_tmp[@]} -gt 4 ] && [ 'x'${_den_tmp[0]} != 'x;;' ]
                then
                    _den_rec=${_den_tmp[3]}
                    _den_nr[${#_den_nr[@]}]=${_den_who}' '${_den_rec}
                    # Début de RFC1033 (+++)
                    case ${_den_rec} in

                         #&lt;name&gt;  [&lt;ttl&gt;]  [&lt;class&gt;]  SOA  &lt;origin&gt;  &lt;person&gt;
                    SOA) # Début de l'autorité
                        if _den_str=$(name_fixup ${_den_tmp[0]})
                        then
                            _den_name[${#_den_name[@]}]=${_den_str}
                            _den_achn[${#_den_achn[@]}]=${_den_who}' '${_den_str}' SOA'
                            #  origine SOA -- nom de domaine de l'enregistrement
                            #+ de la zone maître
                            if _den_str2=$(name_fixup ${_den_tmp[4]})
                            then
                                _den_name[${#_den_name[@]}]=${_den_str2}
                                _den_achn[${#_den_achn[@]}]=${_den_who}' '${_den_str2}' SOA.O'
                            fi
                            # Adresse mail responsable (peut-être boguée).
                            # Possibilité d'un premier.dernier@domaine.nom
                            # ignoré.
                            set -f
                            if _den_str2=$(name_fixup ${_den_tmp[5]})
                            then
                                IFS=${ADR_IFS}
                                _den_auth=( ${_den_str2} )
                                IFS=${WSP_IFS}
                                if [ ${#_den_auth[@]} -gt 2 ]
                                then
                                     _den_cont=${_den_auth[1]}
                                     for (( _auth = 2 ; _auth < ${#_den_auth[@]}
; _auth++ ))
                                     do
                                      
_den_cont=${_den_cont}'.'${_den_auth[${_auth}]}
                                     done
                                     _den_name[${#_den_name[@]}]=${_den_cont}'.'
                                     _den_achn[${#_den_achn[@]}]=${_den_who}'
'${_den_cont}'. SOA.C'
                                fi
                            fi
                            set +f
                        fi
                    ;;


                    A) # Enregistrement d'adresse IP(v4)
                        if _den_str=$(name_fixup ${_den_tmp[0]})
                        then
                            _den_name[${#_den_name[@]}]=${_den_str}
                            _den_pair[${#_den_pair[@]}]=${_den_tmp[4]}' '${_den_str}
                            _den_na[${#_den_na[@]}]=${_den_str}' '${_den_tmp[4]}
                            _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' A'
                        else
                            _den_pair[${#_den_pair[@]}]=${_den_tmp[4]}' unknown.domain'
                            _den_na[${#_den_na[@]}]='unknown.domain '${_den_tmp[4]}
                            _den_ref[${#_den_ref[@]}]=${_den_who}' unknown.domain A'
                        fi
                        _den_address[${#_den_address[@]}]=${_den_tmp[4]}
                        _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_tmp[4]}
                    ;;

                    NS) #  Enregistrement du nom de serveur
                        #  Nom de domaine en cours de service (peut être autre
                        #+ chose que l'actuel)
                        if _den_str=$(name_fixup ${_den_tmp[0]})
                        then
                            _den_name[${#_den_name[@]}]=${_den_str}
                            _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' NS'

                            # Nom du domaine du fournisseur de services
                            if _den_str2=$(name_fixup ${_den_tmp[4]})
                            then
                                _den_name[${#_den_name[@]}]=${_den_str2}
                                _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str2}' NSH'
                                _den_ns[${#_den_ns[@]}]=${_den_str2}' NS'
                                _den_pc[${#_den_pc[@]}]=${_den_str}' '${_den_str2}
                            fi
                        fi
                    ;;

                    MX) # Enregistrement du serveur de mails
                        # Nom de domaine en service (jokers non gérés ici)
                        if _den_str=$(name_fixup ${_den_tmp[0]})
                        then
                            _den_name[${#_den_name[@]}]=${_den_str}
                            _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' MX'
                        fi
                        # Nom du domaine du fournisseur de service
                        if _den_str=$(name_fixup ${_den_tmp[5]})
                        then
                            _den_name[${#_den_name[@]}]=${_den_str}
                            _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' MXH'
                            _den_ns[${#_den_ns[@]}]=${_den_str}' MX'
                            _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_str}
                        fi
                    ;;

                    PTR) # Enregistrement de l'adresse inverse
                         # Nom spécial
                        if _den_str=$(name_fixup ${_den_tmp[0]})
                        then
                            _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' PTR'
                            # Nom d'hôte (pas un CNAME)
                            if _den_str2=$(name_fixup ${_den_tmp[4]})
                            then
                                _den_rev[${#_den_rev[@]}]=${_den_str}' '${_den_str2}
                                _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str2}' PTRH'
                                _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_str}
                            fi
                        fi
                    ;;

                    AAAA) # Enregistrement de l'adresse IP(v6)
                        if _den_str=$(name_fixup ${_den_tmp[0]})
                        then
                            _den_name[${#_den_name[@]}]=${_den_str}
                            _den_pair[${#_den_pair[@]}]=${_den_tmp[4]}' '${_den_str}
                            _den_na[${#_den_na[@]}]=${_den_str}' '${_den_tmp[4]}
                            _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' AAAA'
                        else
                            _den_pair[${#_den_pair[@]}]=${_den_tmp[4]}' unknown.domain'
                            _den_na[${#_den_na[@]}]='unknown.domain '${_den_tmp[4]}
                            _den_ref[${#_den_ref[@]}]=${_den_who}' unknown.domain'
                        fi
                        # Aucun travaux sur les adresses IPv6
                            _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_tmp[4]}
                    ;;

                    CNAME) # Enregistrement du nom de l'alias
                           # Pseudo
                        if _den_str=$(name_fixup ${_den_tmp[0]})
                        then
                            _den_name[${#_den_name[@]}]=${_den_str}
                            _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' CNAME'
                            _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_str}
                        fi
                        # Nom d'hôte
                        if _den_str=$(name_fixup ${_den_tmp[4]})
                        then
                            _den_name[${#_den_name[@]}]=${_den_str}
                            _den_ref[${#_den_ref[@]}]=${_den_who}' '${_den_str}' CHOST'
                            _den_pc[${#_den_pc[@]}]=${_den_who}' '${_den_str}
                        fi
                    ;;
#                   TXT)
#                   ;;
                    esac
                fi
            done
        else # Erreur de recherche == enregistrement 'A' 'adresse inconnue'
            _den_pair[${#_den_pair[@]}]='0.0.0.0 '${_den_who}
        fi
    done

    # Tableau des points de contrôle grandit.
    unique_lines _den_achn _den_achn      # Fonctionne mieux, tout identique.
    edit_exact auth_chain _den_achn       # Fonctionne mieux, éléments uniques.
    if [ ${#_den_achn[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        auth_chain=( ${auth_chain[@]} ${_den_achn[@]} )
        IFS=${WSP_IFS}
    fi

    unique_lines _den_ref _den_ref      # Fonctionne mieux, tout identique.
    edit_exact ref_chain _den_ref       # Fonctionne mieux, éléments uniques.
    if [ ${#_den_ref[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        ref_chain=( ${ref_chain[@]} ${_den_ref[@]} )
        IFS=${WSP_IFS}
    fi

    unique_lines _den_na _den_na
    edit_exact name_address _den_na
    if [ ${#_den_na[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        name_address=( ${name_address[@]} ${_den_na[@]} )
        IFS=${WSP_IFS}
    fi

    unique_lines _den_ns _den_ns
    edit_exact name_srvc _den_ns
    if [ ${#_den_ns[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        name_srvc=( ${name_srvc[@]} ${_den_ns[@]} )
        IFS=${WSP_IFS}
    fi

    unique_lines _den_nr _den_nr
    edit_exact name_resource _den_nr
    if [ ${#_den_nr[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        name_resource=( ${name_resource[@]} ${_den_nr[@]} )
        IFS=${WSP_IFS}
    fi

    unique_lines _den_pc _den_pc
    edit_exact parent_child _den_pc
    if [ ${#_den_pc[@]} -gt 0 ]
    then
        IFS=${NO_WSP}
        parent_child=( ${parent_child[@]} ${_den_pc[@]} )
        IFS=${WSP_IFS}
    fi

    # Mise à jour de la liste known_pair (adresse et nom).
    unique_lines _den_pair _den_pair
    edit_exact known_pair _den_pair
    if [ ${#_den_pair[@]} -gt 0 ]  # Rien de nouveau?
    then
        IFS=${NO_WSP}
        known_pair=( ${known_pair[@]} ${_den_pair[@]} )
        IFS=${WSP_IFS}
    fi

    # Mise à jour de la liste des pairs inversés.
    unique_lines _den_rev _den_rev
    edit_exact reverse_pair _den_rev
    if [ ${#_den_rev[@]} -gt 0 ]   # Rien de nouveau ?
    then
        IFS=${NO_WSP}
        reverse_pair=( ${reverse_pair[@]} ${_den_rev[@]} )
        IFS=${WSP_IFS}
    fi

    # Vérification de la limite d'indirection -- abandon si elle est atteinte.
    if ! _den_lmt=$(limit_chk ${1})
    then
        return 0
    fi

    #  Le moteur d'exécution est LIFO. L'ordre des opérations en attente est
    #+ important.
    # Avons-nous défini de nouvelles adresses ?
    unique_lines _den_address _den_address    # Scrub duplicates.
    edit_exact known_address _den_address     # Scrub already processed.
    edit_exact un_address _den_address        # Scrub already waiting.
    if [ ${#_den_address[@]} -gt 0 ]          # Anything new?
    then
        uc_address=( ${uc_address[@]} ${_den_address[@]} )
        pend_func expand_input_address ${_den_lmt}
        _trace_log[${#_trace_log[@]}]='## Added '${#_den_address[@]}' unchecked address(s). ##'
    fi

    # Avons-nous trouvé de nouveaux noms ?
    unique_lines _den_name _den_name          # Scrub duplicates.
    edit_exact known_name _den_name           # Scrub already processed.
    edit_exact uc_name _den_name              # Scrub already waiting.
    if [ ${#_den_name[@]} -gt 0 ]             # Anything new?
    then
        uc_name=( ${uc_name[@]} ${_den_name[@]} )
        pend_func expand_input_name ${_den_lmt}
        _trace_log[${#_trace_log[@]}]='## Added '${#_den_name[@]}' unchecked name(s). ##'
    fi
    return 0
}

# Réponse de délégation analysez-le-vous-même
# L'entrée est la liste chk_address.
# detail_each_address &lt;indirection_limit&gt;
detail_each_address() {
    [ ${#chk_address[@]} -gt 0 ] || return 0
    unique_lines chk_address chk_address
    edit_exact known_address chk_address
    if [ ${#chk_address[@]} -gt 0 ]
    then
        known_address=( ${known_address[@]} ${chk_address[@]} )
        unset chk_address[@]
    fi
    return 0
}

## Fonctions de sortie spécifiques à l'application ##

# Affiche joliment les pairs connues.
report_pairs() {
    echo
    echo 'Known network pairs.'
    col_print known_pair 2 5 30

    if [ ${#auth_chain[@]} -gt 0 ]
    then
        echo
        echo 'Known chain of authority.'
        col_print auth_chain 2 5 30 55
    fi

    if [ ${#reverse_pair[@]} -gt 0 ]
    then
        echo
        echo 'Known reverse pairs.'
        col_print reverse_pair 2 5 55
    fi
    return 0
}

#  Vérifie une adresse contre la liste des serveurs
#+ faisant partie de la liste noire.
# Un bon endroit pour capturer avec GraphViz :
# address-&gt;status(server(reports))
# check_lists &lt;ip_address&gt;
check_lists() {
    [ $# -eq 1 ] || return 1
    local -a _cl_fwd_addr
    local -a _cl_rev_addr
    local -a _cl_reply
    local -i _cl_rc
    local -i _ls_cnt
    local _cl_dns_addr
    local _cl_lkup

    split_ip ${1} _cl_fwd_addr _cl_rev_addr
    _cl_dns_addr=$(dot_array _cl_rev_addr)'.'
    _ls_cnt=${#list_server[@]}
    echo '    Checking address '${1}
    for (( _cl = 0 ; _cl < _ls_cnt ; _cl++ ))
    do
        _cl_lkup=${_cl_dns_addr}${list_server[${_cl}]}
        if short_text ${_cl_lkup} _cl_reply
        then
            if [ ${#_cl_reply[@]} -gt 0 ]
            then
                echo '        Records from '${list_server[${_cl}]}
                address_hits[${#address_hits[@]}]=${1}' '${list_server[${_cl}]}
                _hs_RC=2
                for (( _clr = 0 ; _clr < ${#_cl_reply[@]} ; _clr++ ))
                do
                    echo '            '${_cl_reply[${_clr}]}
                done
            fi
        fi
    done
    return 0
}

## La colle habituelle de l'application ##

# Qui l'a fait ?
credits() {
   echo
   echo "Guide d'écriture avancée des scripts Bash : is_spammer.bash, v2,
2004-msz"
}

# Comment l'utiliser ?
# (Voir aussi, "Quickstart" à la fin de ce script.)
usage() {
    cat <<-'_usage_statement_'
    Le script is_spammer.bash requiert un ou deux arguments.

    arg 1) Pourrait être :
        a) Un nom de domaine
        b) Une adresse IPv4
        c) Le nom d'un fichier avec des noms et adresses mélangés, un par ligne.

    arg 2) Pourrait être :
        a) Un nom de domaine d'un serveur Blacklist
        b) Le nom d'un fichier contenant une liste de noms de domaine Blacklist,
           un domaine par ligne.
        c) Si non présent, une liste par défaut de serveurs Blacklist (libres)
           est utilisée.
        d) Si un fichier vide, lisible, est donné, la recherche de serveurs
           Blacklist est désactivée.

    Toutes les sorties du script sont écrites sur stdout.

    Codes de retour: 0 -> Tout est OK, 1 -> Échec du script,
                     2 -> Quelque chose fait partie de la liste noire.

    Requiert le programme externe 'dig' provenant des programmes DNS de 'bind-9'
    Voir http://www.isc.org

    La limite de la profondeur de recherche du nom de domaine est par défaut de
    deux niveaux.
    Initialisez la variable d'environnement SPAMMER_LIMIT pour modifier ceci.
    SPAMMER_LIMIT=0 signifie 'illimité'

    La limite peut aussi être initialisée sur la ligne de commande.
    Si arg#1 est un entier, la limite utilise cette valeur
    puis les règles d'arguments ci-dessus sont appliquées.

    Initialiser la variable d'environnemnt 'SPAMMER_DATA' à un nom de fichier
    demandera au script d'écrire un fichier graphique GraphViz.

    Pour la version de développement ;
    Initialiser la variable d'environnement 'SPAMMER_TRACE' avec un nom de
    fichier demandera au moteur d'exécution de tracer tous les appels de
    fonction.

_usage_statement_
}

# La liste par défaut des serveurs Blacklist :
# Plusieurs choix, voir : http://www.spews.org/lists.html

declare -a default_servers
# Voir : http://www.spamhaus.org (Conservateur, bien maintenu)
default_servers[0]='sbl-xbl.spamhaus.org'
# Voir : http://ordb.org (Relais mail ouverts)
default_servers[1]='relays.ordb.org'
# Voir : http://www.spamcop.net/ (Vous pouvez rapporter les spammeurs ici)
default_servers[2]='bl.spamcop.net'
# Voir : http://www.spews.org (Un système de détection rapide)
default_servers[3]='l2.spews.dnsbl.sorbs.net'
# Voir : http://www.dnsbl.us.sorbs.net/using.shtml
default_servers[4]='dnsbl.sorbs.net'
# Voir : http://dsbl.org/usage (Différentes listes de relai de mail)
default_servers[5]='list.dsbl.org'
default_servers[6]='multihop.dsbl.org'
default_servers[7]='unconfirmed.dsbl.org'

# Argument utilisateur #1
setup_input() {
    if [ -e ${1} ] && [ -r ${1} ]  # Nom d'un fichier lisible
    then
        file_to_array ${1} uc_name
        echo 'Using filename >'${1}'< as input.'
    else
        if is_address ${1}          # Adresse IP ?
        then
            uc_address=( ${1} )
            echo 'Starting with address >'${1}'<'
        else                       # Doit être un nom.
            uc_name=( ${1} )
            echo 'Starting with domain name >'${1}'<'
        fi
    fi
    return 0
}

# Argument utilisateur #2
setup_servers() {
    if [ -e ${1} ] && [ -r ${1} ]  # Nom d'un fichier lisible
    then
        file_to_array ${1} list_server
        echo 'Using filename >'${1}'< as blacklist server list.'
    else
        list_server=( ${1} )
        echo 'Using blacklist server >'${1}'<'
    fi
    return 0
}

# Variable d'environnement utilisateur SPAMMER_TRACE
live_log_die() {
    if [ ${SPAMMER_TRACE:=} ]    # Journal de trace ?
    then
        if [ ! -e ${SPAMMER_TRACE} ]
        then
            if ! touch ${SPAMMER_TRACE} 2>/dev/null
            then
                pend_func echo $(printf '%q\n' \
                'Unable to create log file >'${SPAMMER_TRACE}'<')
                pend_release
                exit 1
            fi
            _log_file=${SPAMMER_TRACE}
            _pend_hook_=trace_logger
            _log_dump=dump_log
        else
            if [ ! -w ${SPAMMER_TRACE} ]
            then
                pend_func echo $(printf '%q\n' \
                'Unable to write log file >'${SPAMMER_TRACE}'<')
                pend_release
                exit 1
            fi
            _log_file=${SPAMMER_TRACE}
            echo '' > ${_log_file}
            _pend_hook_=trace_logger
            _log_dump=dump_log
        fi
    fi
    return 0
}

# Variable d'environnement utilisateur SPAMMER_DATA
data_capture() {
    if [ ${SPAMMER_DATA:=} ]    # Tracer les données ?
    then
        if [ ! -e ${SPAMMER_DATA} ]
        then
            if ! touch ${SPAMMER_DATA} 2>/dev/null
            then
                pend_func echo $(printf '%q]n' \
                'Unable to create data output file >'${SPAMMER_DATA}'<')
                pend_release
                exit 1
            fi
            _dot_file=${SPAMMER_DATA}
            _dot_dump=dump_dot
        else
            if [ ! -w ${SPAMMER_DATA} ]
            then
                pend_func echo $(printf '%q\n' \
                'Unable to write data output file >'${SPAMMER_DATA}'<')
                pend_release
                exit 1
            fi
            _dot_file=${SPAMMER_DATA}
            _dot_dump=dump_dot
        fi
    fi
    return 0
}

# Réunir les arguments spécifiés par l'utilisateur.
do_user_args() {
    if [ $# -gt 0 ] && is_number $1
    then
        indirect=$1
        shift
    fi

    case $# in                 # L'utilisateur nous traite-t'il correctement?
        1)
            if ! setup_input $1    # Vérification des erreurs.
            then
                pend_release
                $_log_dump
                exit 1
            fi
            list_server=( ${default_servers[@]} )
            _list_cnt=${#list_server[@]}
            echo 'Using default blacklist server list.'
            echo 'Search depth limit: '${indirect}
            ;;
        2)
            if ! setup_input $1    # Vérification des erreurs.
            then
                pend_release
                $_log_dump
                exit 1
            fi
            if ! setup_servers $2  # Vérification des erreurs.
            then
                pend_release
                $_log_dump
                exit 1
            fi
            echo 'Search depth limit: '${indirect}
            ;;
        *)
            pend_func usage
            pend_release
            $_log_dump
            exit 1
            ;;
    esac
    return 0
}

# Un outil à but général de déboguage.
# list_array &lt;array_name&gt;
list_array() {
    [ $# -eq 1 ] || return 1  # Un argument requis.

    local -a _la_lines
    set -f
    local IFS=${NO_WSP}
    eval _la_lines=\(\ \$\{$1\[@\]\}\ \)
    echo
    echo "Element count "${#_la_lines[@]}" array "${1}
    local _ln_cnt=${#_la_lines[@]}

    for (( _i = 0; _i < ${_ln_cnt}; _i++ ))
    do
        echo 'Element '$_i' >'${_la_lines[$_i]}'<'
    done
    set +f
    return 0
}

## Code 'Chez le spammeur' ##
pend_init                               # Initialisation du moteur à pile.
pend_func credits                       # Dernière chose à afficher.

## Gérer l'utilisateur ##
live_log_die                            #  Initialiser le journal de trace de
                                        #+ déboguage.
data_capture                            #  Initialiser le fichier de capture de
                                        #+ données.
echo
do_user_args $@

## N'a pas encore quitté - Il y a donc un peu d'espoir ##
# Groupe de découverte - Le moteur d'exécution est LIFO - queue en ordre
# inverse d'exécution.
_hs_RC=0                                # Code de retour de Chassez le spammeur
pend_mark
    pend_func report_pairs              # Paires nom-adresse rapportées.

    # Les deux detail_* sont des fonctions mutuellement récursives.
    # Elles mettent en queue les fonctions expand_* functions si nécessaire.
    # Ces deux (les dernières de ???) sortent de la récursion.
    pend_func detail_each_address       #  Obtient toutes les ressources
                                        #+ des adresses.
    pend_func detail_each_name          #  Obtient toutes les ressources
                                        #+ des noms.

    #  Les deux expand_* sont des fonctions mutuellement récursives,
    #+ qui mettent en queue les fonctions detail_* supplémentaires si
    #+ nécessaire.
    pend_func expand_input_address 1    #  Étend les noms en entrées par des
                                        #+ adresses.
    pend_func expand_input_name 1       #  Étend les adresses en entrées par des
                                        #+ noms.

    # Commence avec un ensemble unique de noms et d'adresses.
    pend_func unique_lines uc_address uc_address
    pend_func unique_lines uc_name uc_name

    # Entrée mixe séparée de noms et d'adresses.
    pend_func split_input
pend_release

## Paires rapportées -- Liste unique d'adresses IP trouvées
echo
_ip_cnt=${#known_address[@]}
if [ ${#list_server[@]} -eq 0 ]
then
    echo 'Blacklist server list empty, none checked.'
else
    if [ ${_ip_cnt} -eq 0 ]
    then
        echo 'Known address list empty, none checked.'
    else
        _ip_cnt=${_ip_cnt}-1   # Start at top.
        echo 'Checking Blacklist servers.'
        for (( _ip = _ip_cnt ; _ip >= 0 ; _ip-- ))
        do
            pend_func check_lists $( printf '%q\n' ${known_address[$_ip]} )
        done
    fi
fi
pend_release
$_dot_dump                   # Fichier graphique
$_log_dump                   # Trace d'exécution
echo


#########################################
# Exemple de sortie provenant du script #
#########################################
:"-'_is_spammer_outputs_'

./is_spammer.bash 0 web4.alojamentos7.com

Starting with domain name >web4.alojamentos7.com<
Using default blacklist server list.
Search depth limit: 0
.:....::::...:::...:::.......::..::...:::.......::
Known network pairs.
    66.98.208.97             web4.alojamentos7.com.
    66.98.208.97             ns1.alojamentos7.com.
    69.56.202.147            ns2.alojamentos.ws.
    66.98.208.97             alojamentos7.com.
    66.98.208.97             web.alojamentos7.com.
    69.56.202.146            ns1.alojamentos.ws.
    69.56.202.146            alojamentos.ws.
    66.235.180.113           ns1.alojamentos.org.
    66.235.181.192           ns2.alojamentos.org.
    66.235.180.113           alojamentos.org.
    66.235.180.113           web6.alojamentos.org.
    216.234.234.30           ns1.theplanet.com.
    12.96.160.115            ns2.theplanet.com.
    216.185.111.52           mail1.theplanet.com.
    69.56.141.4              spooling.theplanet.com.
    216.185.111.40           theplanet.com.
    216.185.111.40           www.theplanet.com.
    216.185.111.52           mail.theplanet.com.

Checking Blacklist servers.
    Checking address 66.98.208.97
        Records from dnsbl.sorbs.net
            \"Spam Received See: http://www.dnsbl.sorbs.net/lookup.shtml?66.98.208.97\"
    Checking address 69.56.202.147
    Checking address 69.56.202.146
    Checking address 66.235.180.113
    Checking address 66.235.181.192
    Checking address 216.185.111.40
    Checking address 216.234.234.30
    Checking address 12.96.160.115
    Checking address 216.185.111.52
    Checking address 69.56.141.4

Advanced Bash Scripting Guide: is_spammer.bash, v2, 2004-msz

_is_spammer_outputs_

exit ${_hs_RC}

###############################################################
#  Le script ignore tout ce qui se trouve entre ici et la fin #
#+ à cause de la commande 'exit' ci-dessus.                   #
###############################################################



Quickstart
==========

 Prérequis

  Bash version 2.05b ou 3.00 (bash --version)
  Une version de Bash supportant les tableaux. Le support des tableaux est
  inclus dans les configurations par défaut de Bash.

  'dig,' version 9.x.x (dig $HOSTNAME, voir la première ligne en sortie)
  Une version de dig supportant les options +short.
  Voir dig_wrappers.bash pour les détails.


 Prérequis optionnels

  'named', un programme de cache DNS local. N'importe lequel conviendra.
  Faites deux fois : dig $HOSTNAME 
  Vérifier près de la fin de la sortie si vous voyez:
    SERVER: 127.0.0.1#53
  Ceci signifie qu'il fonctionne.


 Support optionnel des graphiques

  'date', un outil standard *nix. (date -R)

  dot un programme pour convertir le fichier de description graphique en
  un diagramme. (dot -V)
  Fait partie de l'ensemble des programmes Graph-Viz.
  Voir [http://www.research.att.com/sw/tools/graphviz||GraphViz]

  'dotty', un éditeur visuel pour les fichiers de description graphique.
  Fait aussi partie de l'ensemble des programmes Graph-Viz.




 Quick Start

Dans le même répertoire que le script is_spammer.bash; 
Lancez : ./is_spammer.bash

 Détails d'utilisation

1. Choix de serveurs Blacklist.

  (a) Pour utiliser les serveurs par défaut, liste intégrée : ne rien faire.

  (b) Pour utiliser votre propre liste : 

    i. Créez un fichier avec un seul serveru Blacklist par ligne.

    ii. Indiquez ce fichier en dernier argument du script.

  (c) Pour utiliser un seul serveur Blacklist : Dernier argument de ce script.

  (d) Pour désactiver les recherches Blacklist :

    i. Créez un fichier vide (touch spammer.nul)
       Le nom du fichier n'a pas d'importance.

    ii. Indiquez ce nom en dernier argument du script.

2. Limite de la profondeur de recherche.

  (a) Pour utiliser la valeur par défaut de 2 : ne rien faire.

  (b) Pour configurer une limite différente : 
      Une limite de 0 signifie illimitée.

    i. export SPAMMER_LIMIT=1
       ou tout autre limite que vous désirez.

    ii. OU indiquez la limite désirée en premier argument de ce script.

3. Journal de trace de l'exécution (optionnel).

  (a) Pour utiliser la configuration par défaut (sans traces) : ne rien faire.

  (b) Pour écrire dans un journal de trace :
      export SPAMMER_TRACE=spammer.log
      ou tout autre nom de fichier que vous voulez.

4. Fichier de description graphique optionnel.

  (a) Pour utiliser la configuration par défaut (sans graphique) : ne rien
      faire.

  (b) Pour écrire un fichier de description graphique Graph-Viz :
      export SPAMMER_DATA=spammer.dot
      ou tout autre nom de fichier que vous voulez.

5. Où commencer la recherche.

  (a) Commencer avec un simple nom de domaine :

    i. Sans limite de recherche sur la ligne de commande : Premier
       argument du script.

    ii. Avec une limite de recherche sur la ligne de commande : Second
        argument du script.

  (b) Commencer avec une simple adresse IP :

    i. Sans limite de recherche sur la ligne de commande : Premier
       argument du script.

    ii. Avec une limite de recherche sur la ligne de commande : Second
        argument du script.

  (c) Commencer avec de nombreux noms et/ou adresses :
      Créer un fichier avec un nom ou une adresse par ligne.
      Le nom du fichier n'a pas d'importance.

    i. Sans limite de recherche sur la ligne de commande : Fichier comme premier
       argument du script.

    ii. Avec une limite de recherche sur la ligne de commande : Fichier comme
        second argument du script.

6. Que faire pour l'affichage en sortie.

  (a) Pour visualiser la sortie à l'écran : ne rien faire.

  (b) Pour sauvegarder la sortie dans un fichier : rediriger stdout vers un
      fichier.

  (c) Pour désactiver la sortie : rediriger stdout vers /dev/null.

7. Fin temporaire de la phase de décision.
   appuyez sur RETURN 
   attendez (sinon, regardez les points et les virgules).

8. De façon optionnelle, vérifiez le code de retour.

  (a) Code de retour 0: Tout est OK

  (b) Code de retour 1: Échec du script de configuration

  (c) Code de retour 2: Quelque chose était sur la liste noire.

9. Où est mon graphe (diagramme) ?

Le script ne produit pas directement un graphe (diagramme).
Il produit seulement un fichier de description graphique. Vous pouvez utiliser
ce fichier qui a été créé par le programme 'dot'.

Jusqu'à l'édition du fichier de description pour décrire les relations que vous
souhaitez montrer, tout ce que vous obtenez est un ensemble de noms et de noms
d'adresses.

Toutes les relations découvertes par le script font partie d'un bloc en
commentaires dans le fichier de description graphique, chacun ayant un en-tête
descriptif.

L'édition requise pour tracer une ligne entre une paire de noeuds peut se faire
avec un éditeur de texte à partir des informations du fichier descripteur. 

Avec ces lignes quelque part dans le fichier descripteur :

# Known domain name nodes

N0000 [label=\"guardproof.info.\"] ;

N0002 [label=\"third.guardproof.info.\"] ;



# Known address nodes

A0000 [label=61.141.32.197] ;



/*

# Known name->address edges

NA0000 third.guardproof.info. 61.141.32.197



# Known parent->child edges

PC0000 guardproof.info. third.guardproof.info.

 */

Modifiez ceci en les lignes suivantes après avoir substitué les identifiants de
noeuds avec les relations :

# Known domain name nodes
N0000 [label=guardproof.info.] ;
N0002 [label=third.guardproof.info.] ;

# Known address nodes
A0000 [label=61.141.32.197] ;

# PC0000 guardproof.info. third.guardproof.info.
N0000->N0002 ;

# NA0000 third.guardproof.info. 61.141.32.197
N0002->A0000 ;

/*
# Known name->address edges
NA0000 third.guardproof.info. 61.141.32.197

# Known parent->child edges
PC0000 guardproof.info. third.guardproof.info.
 */

Lancez le programme 'dot' et vous avez votre premier diagramme réseau.

En plus des formes graphiques habituelles, le fichier de description inclut des
paires/données de format similaires, décrivant les services, les enregistrements
de zones (sous-graphe ?), des adresses sur liste noire et d'autres choses
pouvant être intéressante à inclure dans votre graphe. Cette information
supplémentaire pourrait être affichée comme différentes formes de noeuds,
couleurs, tailles de lignes, etc.

Le fichier de description peut aussi être lu et édité par un script Bash (bien
sûr). Vous devez être capable de trouver la plupart des fonctions requises à
l'intérieur du script is_spammer.bash.

# Fin de Quickstart.

Note Supplémentaire
===================
Michael Zick indique qu'il existe un makeviz.bash interactif sur
le site Web rediris.es. Impossible de donner le lien complet car
ce n'est pas un site accessible publiquement.

