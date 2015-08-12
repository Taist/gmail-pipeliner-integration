React = require 'react'

{ div, input, svg, path } = React.DOM

mui = require 'material-ui'
ThemeManager = new mui.Styles.ThemeManager()
ThemeManager.setTheme ThemeManager.types.LIGHT

{ TextField, Menu, MenuItem } = mui

AwesomeIcons = require './awesomeIcons'

Spinner = require 'spin'

CustomSelectOption = React.createFactory React.createClass
  getInitialState: ->
    backgroundColor: ''

  onClick: ->
    @props.onSelect?(@props)

  onMouseEnter: ->
    @setState backgroundColor: '#ddd'

  onMouseLeave: ->
    @setState backgroundColor: ''

  render: ->
    div {
      onClick: @onClick
      onMouseEnter: @onMouseEnter
      onMouseLeave: @onMouseLeave
      style:
        padding: "2px 16px 2px 4px"
        backgroundColor: @state.backgroundColor
        whiteSpace: 'nowrap'
    }, @props.value

attrName = require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME
dataAttrName = attrName.replace(/^data-/, '').replace /-./g, (a) -> a.slice(1).toUpperCase()

CustomSelect = React.createFactory React.createClass
  #needed for mui ThemeManager
  childContextTypes:
    muiTheme: React.PropTypes.object

  #needed for mui ThemeManager
  getChildContext: () ->
    muiTheme: ThemeManager.getCurrentTheme()

  getInitialState: ->
    isSpinnerActive: false
    textBoxValue: ''
    mode: 'view'
    options: []

  componentDidMount: ->
    document.addEventListener 'keyup', @onKeyUp
    document.addEventListener "mousedown", @onClickOutside

    if @props.selectType is 'search'
      config =
        length: 4
        width: 2
        radius: 4
        className: 'reactSpinner'
      @spinner = new Spinner config
      @spinner.spin @refs.spinnerContainer?.getDOMNode()

  componentWillUnmount: ->
    document.removeEventListener 'keyup', @onKeyUp
    document.removeEventListener "mousedown", @onClickOutside

  onClickOutside: (event) ->
    if event.target.dataset[dataAttrName]?.indexOf(@.getDOMNode().dataset[dataAttrName]) isnt 0
      #target is not a child of the component
      @onClose()

  onKeyUp: (event) ->
    if event.keyCode is 27
      @onClose()

  onClose: ->
    @setState { mode: 'view' }

  updateState: (newProps) ->
    switch newProps.selectType

      when 'static'
        @setState
          selected: newProps.selected
          options: newProps.options or []
          mode: 'view'

      when 'search'
        @setState
          selected: newProps.selected

  componentWillMount: ->
    @updateState @props

  componentWillReceiveProps: (nextProps) ->
    @updateState nextProps

  getInputNode: ->
    container = @refs.inputText?.getDOMNode()
    container.querySelector 'input'

  onSelectOption: (selectedOption) ->
    @getInputNode().value = selectedOption.value
    @setState { options: [selectedOption], mode: 'view' }
    @props.onSelect?(selectedOption)

  onChange: ->
    value = @getInputNode().value
    @setState { isSpinnerActive: true }, =>
      @props.onChange?(value)
      .then (newOptions) =>
        @setState { options: newOptions, isSpinnerActive: false, mode: 'select' }
      .catch (error) =>
        console.log error

  onClickOnInput: ->
    @setState { mode: 'select' }, =>

      optionRect = @refs.selectedOption?.getDOMNode().getBoundingClientRect()

      if optionRect
        container = @refs.optionsContainer.getDOMNode()
        containerRect = container.getBoundingClientRect()

        container.scrollTop = Math.max(
          optionRect.top - optionRect.height * 2 - containerRect.top , 0
        )

  render: ->
    controlWidth = @props.width or '100%'

    div {
      style:
        display: 'inline-block'
        width: controlWidth
        position: 'relative'
    },
      div {}
        # input {
        #   ref: 'inputText'
        #
        #   onChange: @onChange
        #   onMouseDown: @onClickOnInput
        #
        #   readOnly: true if @props.selectType is 'static'
        #
        #   placeholder: @props.placeholder if @props.placeholder
        #
        #   style:
        #     width: controlWidth
        #     boxSizing: 'border-box'
        #     marginBottom: 0
        #     backgroundColor: 'white'
        # }

        React.createElement TextField, {
          ref: 'inputText'

          floatingLabelText: 'Account name'
          # value: @state.clientEmail
          fullWidth: true
          onChange: @onChange
        }

        div {
          style:
            position: 'absolute'
            top: 16
            right: 0
            bottom: 0
            boxSizing: 'border-box'
            width: 24
        },

          svg {
            onMouseDown: @onClickOnInput
            style:
              display: 'inline-block'
              height: 24
              width: 24
              position: 'absolute'
              top: 20
              right: 0
              fill: '#e0e0e0'
              viewBox: '0 0 24 24'
              cursor: 'pointer'
          },
            path { d: 'M7 10l5 5 5-5z'}

          div {
            ref: 'spinnerContainer'
            style:
              position: 'absolute'
              left: '50%'
              top: '55%'
              transform: 'translate(-50%, -50%)'
              backgroundColor: 'white'
              display: if @state.isSpinnerActive then '' else 'none'
          }


      if @state.mode is 'select' and @state.options?.length > 0
        div {
          ref: 'optionsContainer'
          style:
            position: 'absolute'
            border: '1px solid silver'
            borderRadius: 3
            width: controlWidth
            cursor: 'pointer'
            zIndex: 1024
            maxHeight: 128
            overflowY: 'auto'
            overflowX: 'hidden'
            boxSizing: 'border-box'

            backgroundColor: 'white'
        },

          @state.options.map (o) =>
            div { key: o.id }, CustomSelectOption {
              ref: if o.id is @state.selected?.id then 'selectedOption' else undefined
              id: o.id
              value: o.value
              onSelect: @onSelectOption
            }

module.exports = CustomSelect
