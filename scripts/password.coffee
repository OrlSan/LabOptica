###
# Password.js | coffee
#
# Ayuda al usuario a cambiar la contraseña de inicio de sesión de
# su cuenta por una personalizada.
#
# Out: Object { oldPass, newPass }
# In: Object { success, message }
###

$(document).ready () ->
    $('#pass-form').on 'submit', (event) ->
        # Evitamos el envío del formulario
        event.preventDefault()

        # Borrar todas las alertas vigentes.
        $('.alert').remove()

        if $('#new').val() isnt $('#confirm').val()
            $('#pass-form').prepend('<div class="alert alert-warning"><button type="button" class="close" data-dismiss="alert">
                                       <span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                                       <b>Error:</b> La nueva contraseña debe coincidir</div>')
        else
            # Los datos que serán enviados al servidor
            form_data =
                oldPass: $('#old').val()
                newPass: $('#new').val()
            console.log form_data

            # Iniciamos una petición AJAX al servidor Node.js
            $.ajax
                url: '/newPass'
                method: 'POST'
                data: form_data
                success: (data, textStatus, jqXHR) ->
                    response = JSON.parse(jqXHR.responseText)
                    if response.success is true
                        # Insertar una alerta positiva en el HTML para avisar al
                        # usuario que el proceso fue correcto.
                        $('#pass-form').prepend('<div class="alert alert-success"><button type="button" class="close" data-dismiss="alert">
                                                   <span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                                                   <b>Éxito:</b> MSJ</div>'.replace('MSJ', response.message))
                        # Borrar los campos de entrada de datos
                        $('#old').val('')
                        $('#new').val('')
                        $('#confirm').val('')
                    else
                        # Insertar una alerta negativa en el HTML para avisar al
                        # usuario que el proceso fue correcto.
                        $('#pass-form').prepend('<div class="alert alert-warning"><button type="button" class="close" data-dismiss="alert">
                                                   <span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                                                   <b>Error:</b> MSJ</div>'.replace('MSJ', response.message))
                        # Borrar los campos de entrada de datos
                        $('#old').val('')
                        $('#new').val('')
                        $('#confirm').val('')
                    return

                error: (data, textStatus, jqXHR) ->
                    # Insertar una alerta negativa en el HTML para avisar al
                    # usuario que el proceso fue correcto.
                    $('#pass-form').prepend('<div class="alert alert-error"><button type="button" class="close" data-dismiss="alert">
                                               <span aria-hidden="true">&times;</span><span class="sr-only">Close</span></button>
                                               <b>Error:</b> No hay conexión con la aplicación o la respuesta está tardando demasiado.
                                                   Por favor pide ayuda o reintenta enviar el formulario.</div>')
                    # Borrar los campos de entrada de datos
                    $('#old').val('')
                    $('#new').val('')
                    $('#confirm').val('')
                    return
