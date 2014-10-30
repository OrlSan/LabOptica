###
# Datos.coffee | js
#
# Modelo, vista y controlador para interactuar con los datos de
# la aplicación LabOptica para crear, modificar y relacionar los
# datos a través de peticiones a la API.
#
# (c) 2014, Orlando Rey Sánchez.
###

# Creamos el Namespace de la aplicación
App = App or {
    Views: {}
    Models: {}
    Collections: {}
}

# GetUrlParameter, para obtener la URL
GetUrlParameter = (sParam) ->
    sPageURL = window.location.search.substring(1)
    sURLVariables = sPageURL.split('&');
    for item in sURLVariables
        sParameterName = item.split('=')
        if (sParameterName[0] == sParam)
            return sParameterName[1];


# El modelo de los datos
App.Models.Muestra = Backbone.Model.extend {
    # El atributo ID es usado en Backbone para peticiones GET, POST, PUT y
    # DELETE. Por defecto no hay ninguno, pero con esta línea forzamos a que
    # Backbone use el _id asociado desde la aplicación en Mongo
    # Para borrar, por ejemplo, se emite una petición DELETE a como
    # DELETE /datos.json/5437c6f7978584181abb82c5
    idAttribute: '_id'

    initialize: () ->
        this.set('Mensaje', false)
        return

    # Esta es la URL desde la cual se obtienen los datos y con la cual la
    # aplicación interactúa, como para borrar, actualizar y crear (aunque no
    # se van a crear desde aquí) las facturas.
    urlRoot: '/datos.json'
}

# La colección de los datos
App.Collections.ColMuestras = Backbone.Collection.extend {
    model: App.Models.Muestra
    className: 'list-group'
    tagname: 'li'
    lastDate: null
    url: if GetUrlParameter('date') then '/datos.json?date=' + GetUrlParameter("date") else '/datos.json'
    initialize: () ->
        this.fetch({ async: false })
        return
}

# Un view para todas la colección de datos.
App.Views.GlobalView = Backbone.View.extend {
    tagname: 'ul'
    className: 'list-group'
    render: () ->
        this.collection.each (data) ->
            singleView = new App.Views.SingleDataView({ model: data })
            this.$el.append(singleView.render().el)
        , this
        return this

    initialize: (options) ->
        # Escuchar por si agregan el elemento nuevo.
        $('.addbtn').bind 'click', this.addData

        # this.listenTo(this.collection, 'add remove', this.render)
        return


    addData: () ->
        properties = {
            Number: $('#number').val()
            Gender: $('#gender').val()
            Color:  $('#color').val()
            Tinte:  $('#tinte').val()
        }

        muestra = new App.Models.Muestra(properties)

        # Guardamos la muestra en el servidor
        muestra.save(properties, {
            success: (model, response, options) ->
                if response.success
                    # Borramos los datos y reiniciamos el formulario
                    $('#number').val('')
                    $('#gender').val('hombre')
                    $('#color').val( 'castano' )
                    $('#tinte').val('false')
                    App.col.add(response.model)
                else
                    alert response.message
                    App.col.reset()
        })

}

# El view individual de los datos
App.Views.SingleDataView = Backbone.View.extend {
    tagName: 'li'
    myTemplate: _.template( $('#dataTemplate').html() )
    className: 'list-group-item'
    initialize: () ->
        this.model.on('change', this.render, this)
        return

    render: () ->
        this.$el.html this.myTemplate(this.model.attributes)
        return this

    events: {
        'click .btn-danger': 'deleteData'
        'click .btn-primary': 'updateData'
        'change input#medida': 'setMedida'
        'change input#incert': 'setIncert'
    }

    setMedida: (e) ->
        value = $(e.currentTarget).val()
        this.model.set('Medida', value)

    setIncert: (e) ->
        value = $(e.currentTarget).val()
        this.model.set('Incert', value)

    deleteData: () ->
        console.log "Borrando el registro con el ID #{this.model.get('_id')}"
        # Comenzamos la petición de destrucción
        this.model.destroy {
            success: (model, response, options) ->
                # Eliminamos el atributo que pide la cancelación
                if response.success
                    model.set('Mensaje', response.message)
                    model.set('Vigente', false)
                    App.col.remove(model)
                else
                    console.log "No se pudo eliminar: #{response.message}"
                    model.set('Mensaje', response.message)
                return

            error: (model, xhr, options) ->
                console.log xhr
                model.set('Mensaje', 'Hubo un error de comunicación. Recarga la página.')
                return
        }
        return

    updateData: () ->
        console.log "Actualizando el registro #{JSON.stringify(this.model.attributes)}"
        this.model.save this.model.attributes, {
            success: (model, response, options) ->
                console.log response
                model.set('Mensaje', response.message)
            error: (model, xhr, options) ->
                console.log xhr
                model.set('Mensaje', 'Hubo un error de comunicación. Recarga la página.')
        }
        return

}

# creamos una instancia de la colección
App.col = new App.Collections.ColMuestras()

# Creamos un View nuevo de la colección
App.globView = new App.Views.GlobalView { collection: App.col }

$(".pantalla").html App.globView.render().el

$('form').on 'submit', (event) ->
    App.col = new App.Collections.ColMuestras()
    event.preventDefault()
