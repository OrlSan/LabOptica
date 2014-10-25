###
# Datos.coffee | js
#
# Modelo, vista y controlador para interactuar con los datos de
# la aplicación LabOptica para crear, modificar y relacionar los
# datos a través de peticiones a la API.
#
# (c) 2014, Orlando Rey Sánchez.
###

# GetUrlParameter, para obtener la URL
GetUrlParameter = (sParam) ->
    sPageURL = window.location.search.substring(1)
    sURLVariables = sPageURL.split('&');
    for item in sURLVariables
        sParameterName = item.split('=')
        if (sParameterName[0] == sParam)
            return sParameterName[1];

# El modelo de los datos
Muestra = Backbone.Model.extend {
    # El atributo ID es usado en Backbone para peticiones GET, POST, PUT y
    # DELETE. Por defecto no hay ninguno, pero con esta línea forzamos a que
    # Backbone use el _id asociado desde la aplicación en Mongo
    # Para borrar, por ejemplo, se emite una petición DELETE a como
    # DELETE /datos.json/5437c6f7978584181abb82c5
    idAttribute: '_id'
    initialize: () ->
        # console.log "Creando la factura " + JSON.stringify(this.attributes)
        this.set('Mensaje', false)
        return

    # Esta es la URL desde la cual se obtienen los datos y con la cual la
    # aplicación interactúa, como para borrar, actualizar y crear (aunque no
    # se van a crear desde aquí) las facturas.
    urlRoot: '/datos.json'
}

# La colección de los datos
ColMuestras = Backbone.Collection.extend {
    model: Muestra
    className: 'list-group'
    tagname: 'li'
    lastDate: null
    url: if GetUrlParameter('date') then '/datos.json?date=' + GetUrlParameter("date") else '/datos.json'
    initialize: () ->
        console.log this.url
        this.fetch({ async: false })
        return
}

# Un view para todas la colección de datos.
GlobalView = Backbone.View.extend {
    tagname: 'ul'
    className: 'list-group'
    render: () ->
        this.collection.each (data) ->
            singleView = new SingleDataView({ model: data })
            this.$el.append(singleView.render().el)
        , this
        return this

    initialize: (options) ->
        this.listenTo(this.collection, 'add remove', this.render)
        return
}

# El view individual de los datos
# El View individual de la factura
SingleDataView = Backbone.View.extend {
    tagName: 'li'
    myTemplate: _.template( $('#dataTemplate').html() )
    className: 'list-group-item'
    initialize: () ->
        this.model.on('change', this.render, this)
        return

    render: () ->
        this.$el.html this.myTemplate(this.model.attributes)
        return this
}

# creamos una instancia de la colección
col = new ColMuestras()

# Creamos un View nuevo de la colección
globView = new GlobalView { collection: col }

$(".pantalla").html globView.render().el

$('form').on 'submit', (event) ->
    event.preventDefault()
