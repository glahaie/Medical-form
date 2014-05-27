#Page de modification de dossier

#Pour l'ajout et le retrait de blocs d'antécédents, suivis, notes, etc...
#source: http://stackoverflow.com/questions/9173182/add-remove-input-field-dynamically-with-jquery
($ document).ready ->

    ajouteElement verifierAjax,
        id_fieldset: '#antecedents'
        id_click: '#antecedent'
        date: 'date_antecedent'
        'date_msg_req' : 'Vous devez entrer une date d\'antécédent.'
        'date_msg_pattern' : 'Format de date illégal.'
        description: 'description_antecedent'
        'description_msg_req' : 'Vous devez entrer une description d\'antécédent.'
        'bouton_msg' : 'Enlever cet antécédent'
    ajouteElement verifierAjax,
        id_fieldset: '#suivis'
        id_click: '#suivi'
        date: 'date_suivi'
        'date_msg_req' : 'Vous devez entrer une date de suivi.'
        'date_msg_pattern' : 'Format de date illégal.'
        description: 'description_suivi'
        'description_msg_req' : 'Vous devez entrer une description de suivi.'
        'bouton_msg' : 'Enlever ce suivi'
    ajouteElement verifierAjax,
        id_fieldset: '#notes'
        id_click: '#note'
        date: 'date_note'
        'date_msg_req' : 'Vous devez entrer une date de note'
        'date_msg_pattern' : 'Format de date illégal.'
        description: 'description_note'
        'description_msg_req' : 'Vous devez entrer une description de note.'
        'bouton_msg' : 'Enlever cette note'
    ajouteElement verifierAjax,
        id_fieldset: '#visites'
        id_click: '#visite'
        date: 'date_visite'
        'date_msg_req' : 'Vous devez entrer une date de visite.'
        'date_msg_pattern' : 'Format de date illégal.'
        description: 'description_visite'
        'description_msg_req' : 'Vous devez entrer une description de visite.'
        'bouton_msg' : 'Enlever cette visite'

#On ajoute l'action pour effacer une note, un antécédent, un suivi, une visite
#aux éléments déjà présents du dossier.
($ document).ready ->
   ($ '.remove').click ->
       ($ this).parent().parent().parent().remove()
       verifierAjax()

#Pour l'enregistrement automatique, on ajoute le change sur tous les éléments
#du formulaire.
($ document).ready ->
    ($ 'input, textarea, select').change ->
        verifierAjax()


#Pour la validation du formulaire avec jquery validate. 
#Plusieurs sources pour ces fonctions:
#http://jqueryvalidation.org/validate
#http://stackoverflow.com/questions/10082330/dynamically-create-bootstrap-alerts-box-through-javascript
#http://alittlecode.com/files/jQuery-Validate-Demo/index.html
($ document).ready ->
   form =  ($ '.myform').validate
        invalidHandler : (event, validator) ->
            afficherErreur()
        submitHandler: () ->
            return false

#Vérification du formulaire, si tout passe, on enregistre, sinon on montre
#les erreurs.
verifierAjax = () ->
    isValid = ($ ".myform").valid()
    if isValid
        donnees = ($ ".myform").serialize()
        $.ajax
            type:"POST"
            url: "/modifierDossier"
            data: donnees
            dataType: 'json'
            success: (data) ->
                alert = $ '<div>',
                    class:'alert alert-success'
                    text: data.message
                alert.append $ '<a>',
                    href:'#'
                    class:'close'
                    'data-dismiss':'alert'
                    text:'x'
                ($ "#alert_placeholder").empty().append alert
                alert.fadeTo 5000, 0
            error: (request, status, error) ->
                afficherErreur(status)

