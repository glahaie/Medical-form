// Generated by CoffeeScript 1.6.3
($(document)).ready(function() {
  return ajouteElement(null, {
    id_fieldset: '#antecedents',
    id_click: '#antecedent',
    date: 'date_antecedent',
    'date_msg_req': 'Vous devez entrer une date d\'antécédent.',
    'date_msg_pattern': 'Format de date illégal.',
    description: 'description_antecedent',
    'description_msg_req': 'Vous devez entrer une description d\'antécédent.',
    'bouton_msg': 'Enlever cet antécédent'
  });
});

($(document)).ready(function() {
  return $('form').validate({
    invalidHandler: function(event, validator) {
      return afficherErreur();
    }
  });
});
