
#Pour l'ajout et le retrait de blocs d'antécédents
#source: http://stackoverflow.com/questions/9173182/add-remove-input-field-dynamically-with-jquery
($ document).ready ->
    ajouteElement null,
        id_fieldset: '#antecedents'
        id_click: '#antecedent'
        date: 'date_antecedent'
        'date_msg_req' : 'Vous devez entrer une date d\'antécédent.'
        'date_msg_pattern' : 'Format de date illégal.'
        description: 'description_antecedent'
        'description_msg_req' : 'Vous devez entrer une description d\'antécédent.'
        'bouton_msg' : 'Enlever cet antécédent'

#Validation du formulaire, avant l'envoi, utilise jquery validator
($ document).ready ->
    $('form').validate
        invalidHandler : (event, validator) ->
            afficherErreur()
