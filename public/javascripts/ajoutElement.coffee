#Fonctions utilisées pour le traitement des antécédents, des suivis, des notes
#et des visites. 

#Fonction qui ajoute dynamiquement des champs pour les données requises. C'est
#surtout long à cause de la structure des pages.
ajouteElement =  (actionFormulaire, donnees) ->
    ($ "#{donnees.id_click}").click () ->
        temp = ($ "#{donnees.id_fieldset} div.row-fluid").find("input[id^=#{donnees.date}]").last().attr 'id'
        intId = if temp is undefined then 1 else (parseInt (temp.replace /[a-zA-Z_]/g, ""), 10) + 1

        #Pour le moment, je le fais comme ça en coffeescript, pas sur comment le faire avec
        #l'autre définition d'un objet
        wrapper = ($ '<div>',
            'class': 'row-fluid' ).appendTo "#{donnees.id_fieldset}"
        dSpan1 = ($ '<div>',
            'class': 'span6' ).appendTo wrapper
        dControl1 = ($ '<div>',
            'class': 'control-group' ).appendTo dSpan1
        dControl1.append ($ '<label>',
            'for':"#{donnees.date}#{intId}"
            'class':'control-label' ).text 'Date'
        dControls1 = ($ '<div>',
            'class':'controls' ).appendTo dControl1
        inputDate = $ '<input>',
            type : 'text'
            id : donnees.date + intId
            name : donnees.date + intId
            placeholder : 'AAAA-MM-JJ'
            pattern : '[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])'
            required : true
            'data-msg-required' : donnees.date_msg_req
            'data-msg-pattern' : donnees.date_msg_pattern
        dControls1.append inputDate
        inputDate.change ->
            actionFormulaire()

        #Maintenant pour la description
        dSpan2 = ($ '<div>',
            'class': 'span6' ).appendTo wrapper
        dControl2 = ($ '<div>',
            'class': 'control-group' ).appendTo dSpan2
        dControl2.append $ '<label>',
            for: donnees.description+intId
            class: 'control-label'
            text:'Description'
        dControls2 = ($ '<div>',
            class:'controls' ).appendTo dControl2
        inputDesc = $ '<textarea>',
            id: donnees.description+intId
            name:donnees.description+intId
            required:true
            'data-msg-required': donnees.description_msg_req
        dControl2.append inputDesc
        inputDesc.change ->
            actionFormulaire()

        #Bouton pour enlever
        enlever = $ '<input>',
            type : 'button'
            class:'remove btn btn-primary'
            value: donnees.bouton_msg
        enleverDiv = ($ '<div>',
            class: 'row-fluid' ).appendTo wrapper
        enleverSpan = ($ '<div>',
            class: 'span6' ).appendTo enleverDiv
        enlever.appendTo enleverSpan
        enlever.click ->
            ($ this).parent().parent().parent().remove()
            actionFormulaire() if actionFormulaire

#Afficher un message d'erreur
afficherErreur = (status) ->
    erreur = $ '<div>',
        class:'alert alert-error'
    if status
        erreur.text 'Une erreur s\'est produite lors de la sauvegarde du formulaire'
    else
        erreur.text 'Le formulaire contient au moins une erreur.'
    erreur.append $ '<a>',
        class: 'close'
        'data-dismiss':'alert'
        text:'x'
    ($ "#alert_placeholder").empty().append erreur
    erreur.fadeTo 5000,0.01

