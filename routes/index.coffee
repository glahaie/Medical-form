fs = require "fs"
xml2js = require "xml2js"
xmldom = require "xmldom"
pd = (require 'pretty-data').pd; #Pour que le fichier xml reste lisible
moment = require 'moment' #Problème avec les dates de JS, donc moment.js
stable = require 'stable'

#Chemin pour le fichier contenant les données
cheminXML = "donnees/dossier.xml"

#*************************** Fonctions de routage ****************************

#Affiche une liste des dossiers de patients en ordre de leur numéro de dossiers
exports.index = (req, res) ->
    trierDossiers cheminXML, (err, dossiersTries) ->
        if err
            res.render 'erreur',
                title: 'Erreur'
                'erreur': err
        else
            res.render 'list',
                title: 'Liste des patients'
                dossier:dossiersTries

#Affiche le formulaire de saisie d'un nouveau dossier.
exports.nouveau = (req, res) ->
    res.render 'nouveau',
        title: 'Nouveau dossier'

#Affiche les informations d'un dossier d'après le numéro de dossier.
exports.dossier = (req, res) ->

    obtenirDossier cheminXML, req.params.noDossier, (err, dossier) ->
        if err is 404
            res.render '404',
                title: 'Page inexistante'
                status:404
        else if err is 500
            res.render 'erreur',
                title:'Erreur'
                erreur:'Numéro inexistant'
        else if err
            res.render 'erreur',
                title: 'Erreur',
                erreur:err
        else
            nettoyerDossier dossier, (err, result) ->
                if err
                    res.render 'erreur',
                        title:'Erreur'
                        erreur: 'Erreur de traitement des informations.'
                        status:500
                else
                    noDossier = result.numero
                    res.render 'dossier',
                        title: 'Dossier numéro ' + noDossier
                        dossier:result

#Affiche les informations d'un dossier d'après le numéro de dossier.
exports.modifier = (req, res) ->

    obtenirDossier cheminXML, req.params.noDossier, (err, dossier) ->
        if err is 404
            res.render '404',
                title: 'Page inexistante'
                status:404
        else if err is 500
            res.render 'erreur',
                title:'Erreur'
                erreur:'Numéro inexistant'
                status:500
        else if err
            res.render 'erreur',
                title: 'Erreur'
                erreur:err
        else
            nettoyerDossier dossier, (err, result) ->
                if err
                    res.render 'erreur',
                        title: 'Erreur'
                        erreur: 'Erreur de traitement'
                        status:500
                else
                    noDossier = result.numero
                    res.render 'modifier',
                        title: 'Modification du dossier numéro ' + noDossier
                        dossier:result


#Ajoute les données du nouveau dossier au document XML et redirige
#vers la page affichant les données du dossier.
exports.nouveauDossier = (req, res) ->
    insererDossier cheminXML, req.body, (err, url) ->
       if err
          res.render 'erreur',
            title:err
       else
          res.redirect url

#Trouve les suivis à afficher, et les affiches
exports.suivis = (req, res) ->

    classerSuivis cheminXML, (err, result) ->
        if err
            res.render '500',
                title: "Erreur lors du traitement"
                status:500
        else
            res.render 'suivis',
                title: "Suivis de la journée",
                suivis:result

#On recoit un dossier modifié, on le change dans le xml
exports.modifierDossier = (req, res) ->
    donnees = req.body
    mettreAJourDossier cheminXML,donnees, (err, success) ->
        if err
            res.send(500)
        else
            res.json
                message: 'Formulaire enregistré.'


#************************* Fonctions de traitement ***************************

#Pour l'ajout d'un nouveau dossier.
#On ouvre le fichier XML, on parse, et on appel ajouterDossier,
insererDossier = (fichierXML, donnees, callback) ->
    fs.readFile fichierXML, (err, data) ->
        if err
            callback err
        else
            #On parse le fichier existant
            xmlDoc = (new xmldom.DOMParser()).parseFromString data.toString()
            ajouterDossier donnees, xmlDoc, callback

#Pour la mise à jour d'un dossier.
#On efface tout d'abord le dossier, et ensuite on crée un nouveau dossier
mettreAJourDossier = (fichier, donnees, callback) ->
    fs.readFile fichier, (err, data) ->
        if err
            callback err
        else
            xmlDoc = (new xmldom.DOMParser()).parseFromString data.toString()
            dossiers = xmlDoc.getElementsByTagName 'dossier'
            for dossier in dossiers
                if (dossier.getElementsByTagName 'numero')[0].textContent is donnees.numero
                    xmlDoc.documentElement.removeChild dossier
                    break
            ajouterDossier donnees, xmlDoc, callback


#Fonction qui rend plus facile dans jade le traitement du dossier, à savoir
#si un élément du style antécédent, suivi, visite est vide ou non, cela
#enlève aussi un niveau de listes créé par xml2js
nettoyerDossier = (dossier, callback) ->
    if dossier.antecedents[0] is ""
        dossier.antecedents = undefined
    else
        dossier.antecedents = dossier.antecedents[0].antecedent
    if dossier.notes[0] is ""
        dossier.notes = undefined
    else
        dossier.notes = dossier.notes[0].note
    if dossier.visites[0] is ""
        dossier.visites = undefined
    else
        dossier.visites = dossier.visites[0].visite
    if dossier.suivis[0] is ""
        dossier.suivis = undefined
    else
        dossier.suivis = dossier.suivis[0].suivi
    callback null, dossier

#Fonction qui cherche le fichier pour trouver le dossier ayant le numéro
#donné en argument.
obtenirDossier = (fichier, numero, callback) ->
    fs.readFile fichier, (err, data) ->
        if err
            callback err
        else
            parser = new xml2js.Parser
            parser.parseString data, (err, result) ->
                if err
                    callback err
                else if not isNormalInteger numero
                    callback 404
                else
                    noDossier = parseInt numero, 10
                    indexDossier = chercherDossier result.dossiers, numero
                    if indexDossier < 0
                        callback 500
                    else
                        dossier = result.dossiers.dossier[indexDossier]
                        callback null, dossier

#Fonction qui prend les informations du fichier XML, extrait
#les informations nécessaires, et ensuite les effectue un tri.
trierDossiers = (fichier, callback) ->
    fs.readFile fichier, (err, data) ->
        if err
            callback err
        else
            parser = new xml2js.Parser
            parser.parseString data, (err, result) ->
                if err
                    callback err
                else
                    #Maintenant on peut faire le sort
                    dossiers = result.dossiers.dossier
                    resultat = []

                    #On prepare un objet avec seulement les infos
                    #nécessaires pour la liste.
                    for dossier in dossiers
                        temp =
                            'nom' : dossier.nom
                            'prenom' : dossier.prenom
                            'numero' : dossier.numero
                        #On prend la date de la derniere visite
                        if not (dossier.visites[0] is '')
                            temp.date = derniereDate dossier
                        resultat.push temp

                    #Maintenant un sort sur les numéros de dossiers
                    resultat = stable resultat,cmpNoms
                    callback null, resultat

#Fonction qui prend les données d'un dossier à ajouter et
#qui l'insère dans le fichier XML, en créant un numéro de dossier
#unique.
ajouterDossier = (dossierData, xmlDoc, callback) ->

    #On vérifie si on a besoin d'un nouveau numéro
    if dossierData.numero
        nouveauNo = dossierData.numero
    else
        #On trouve le nouveau numéro
        nouveauNo = obtenirNouveauNumero xmlDoc
    #On crée le nouveau dossier.
    dossier = xmlDoc.createElement 'dossier'

    #On ajoute le numero de dossier et la date de création
    dossier.appendChild ajouterElement xmlDoc,'numero',nouveauNo

    #Ajout de la date d'ouverture, qui est aujourd'hui, si pas défini
    if dossierData.date_ouverture
        dossier.appendChild ajouterElement xmlDoc,'date_ouverture',dossierData.date_ouverture
    else
        dossier.appendChild ajouterElement xmlDoc,'date_ouverture',obtenirDateOuverture()

    notes = xmlDoc.createElement 'notes'
    visites = xmlDoc.createElement 'visites'
    suivis = xmlDoc.createElement 'suivis'
    antecedents = xmlDoc.createElement 'antecedents'

    #Pour les nouveaux dossiers.
    if dossierData.date_fermeture is undefined
        dossier.appendChild xmlDoc.createElement 'date_fermeture'

    #On traite les informations entrées par l'utilisateur.
    reg = new RegExp '^nom|prenom|sexe|telephone|date_naissance|no_ass_maladie|rue|appartement|ville|province|code_postal|date_fermeture$'
    for key,value of dossierData
        if reg.test key
            dossier.appendChild ajouterElement xmlDoc,key,value
        else if (/^date_antecedent[0-9]*$/).test key
            node = xmlDoc.createElement 'antecedent'
            node.appendChild ajouterElement xmlDoc,'date',value
        else if (/^description_antecedent[0-9]*$/).test key
            node.appendChild ajouterElement xmlDoc,'description', value
            antecedents.appendChild node
        else if (/^date_suivi[0-9]*$/).test key
            node = xmlDoc.createElement 'suivi'
            node.appendChild ajouterElement xmlDoc,'date',value
        else if (/^description_suivi[0-9]*$/).test key
            node.appendChild ajouterElement xmlDoc,'description', value
            suivis.appendChild node
        else if (/^date_note[0-9]*$/).test key
            node = xmlDoc.createElement 'note'
            node.appendChild ajouterElement xmlDoc,'date',value
        else if (/^description_note[0-9]*$/).test key
            node.appendChild ajouterElement xmlDoc,'description', value
            notes.appendChild node
        else if (/^date_visite[0-9]*$/).test key
            node = xmlDoc.createElement 'visite'
            node.appendChild ajouterElement xmlDoc,'date',value
        else if (/^description_visite[0-9]*$/).test key
            node.appendChild ajouterElement xmlDoc,'description', value
            visites.appendChild node

    #on ajoute les listes, et le nouveau dossier au dom.
    dossier.appendChild antecedents
    dossier.appendChild notes
    dossier.appendChild suivis
    dossier.appendChild visites
    xmlDoc.documentElement.appendChild dossier

    #On écrit le fichier XML mis à jour.
    str = (new xmldom.XMLSerializer()).serializeToString xmlDoc
    fs.writeFile cheminXML, (pd.xml str) , () ->
        callback null, '/'+nouveauNo

#Fonction qui produit un nouveau numéro, en trouvant le
#plus grand numéro de dossier et en l'augmentant de 1
obtenirNouveauNumero = (xmlDoc) ->
    numDossiers = xmlDoc.getElementsByTagName 'dossier'
    maxNo = -1
    for numDossier in numDossiers
        noDossier =
            parseInt (numDossier.getElementsByTagName 'numero')[0].textContent, 10
        if noDossier > maxNo
            maxNo = noDossier
    return if maxNo is -1 then  1 else maxNo+1


#Ajoute l'élément contenant le texte node dans le xmldom
ajouterElement =(xmlDoc,element, node) ->
    textNode = xmlDoc.createTextNode node
    elementToAdd = xmlDoc.createElement element
    elementToAdd.appendChild textNode
    return elementToAdd

#Trouvé de stackOverflow - utilisateur T.J. Crowder. Fonction pour
#vérifier si une chaine peut être transformé en entier - la version
#avec les expressions régulières
#url : http://stackoverflow.com/questions/10834796/validate-that-a-string-is-a-positive-integer
isNormalInteger = (str) ->
    return (/^\+?(0|[1-9]\d*)$/).test str

#Comparateur pour l'ordre des visites d'un dossier. On retourne
#l'inverse ici pour avoir l'ordre décroissant.
comparerVisites = (visite1, visite2) ->
    date1 = obtenirDate visite1.date[0]
    date2 = obtenirDate visite2.date[0]
    if date1 < date2
        return -1
    if date1 > date2
        return 1
    return 0

#Transforme la chaine date du dossier en objet moment.
#Je met les heures, minutes, etc à 0 pour avoir une comparaison
#de dates plus facile
obtenirDate = (visite) ->
    if visite
        date = moment(visite)
    else
        date = moment()
    date.hour  0
    date.minute  0
    date.second  0
    date.millisecond  0
    return date

#Cherche la position dans le tableau du dossier ayant le
#numéro recherché.
chercherDossier = (dossiers, noDossier) ->
    for element, index  in dossiers.dossier
        if element.numero[0] is noDossier
            return index
    return -1

#Parcours les visites du dossier pour trouver la dernière date
derniereDate= (dossier) ->
    dateMax = dossier.visites[0].visite[0]
    for visite in dossier.visites[0].visite
        if (comparerVisites dateMax, visite) < 0
            dateMax = visite
    return dateMax.date

#Retourne une chaine de caractères de la date d'aujourd'hui.
obtenirDateOuverture = () ->
    return moment().format('YYYY-MM-DD')

#Traverse les dossiers pour obtenir les suivis passés et de la journée
classerSuivis = (fichierXML, callback) ->
    fs.readFile fichierXML, (err, data) ->
        if err
            callback err
        else
            parser = new xml2js.Parser
            parser.parseString data, (err, result) ->
                if err
                    callback err
                else
                    #On traverse le json pour trouver les suivis requis
                    auj = obtenirDate()
                    suivis = []
                    for dossier in result.dossiers.dossier
                        if not (dossier.suivis[0] is '')
                            for suivi in dossier.suivis[0].suivi
                                if suivi.date
                                    temp = obtenirDate suivi.date[0]
                                    if (temp.isBefore auj) or (temp.isSame auj)
                                        #On ajoute au tableau
                                        suivis.push
                                            dossierNo: dossier.numero
                                            dateSuivi: suivi.date[0]
                                            descSuivi: suivi.description
                                            auj: temp.isSame auj

                    #Maintenant on fait un sort
                    suivis = stable suivis,cmpSuivis
                    callback null, suivis

#Règle de comparaison pour la page d'accueil
cmpNoms = (a,b) ->
    result = a.nom[0].toLowerCase().localeCompare b.nom[0].toLowerCase()
    if result is 0
        return a.prenom[0].toLowerCase().localeCompare b.prenom[0].toLowerCase()
    else
        return result

#Règle de comparaison pour les dates de suivi
cmpSuivis = (a, b) ->
    dateA = obtenirDate a.dateSuivi
    dateB = obtenirDate b.dateSuivi
    if dateB.isBefore dateA
        return -1
    else if dateA.isBefore dateB
        return 1
    return 0
