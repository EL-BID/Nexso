

function getStyle() {
    var styles = [
        {
            "stylers": [
              { "visibility": "off" }
            ]
        }, {
            "featureType": "landscape",
            "elementType": "geometry",
            "stylers": [
              { "color": "#80b63f" },
              { "visibility": "on" }
            ]
        }, {
            "featureType": "water",
            "stylers": [
              { "visibility": "on" },
              { "color": "#ffffff" }
            ]
        }, {
            "featureType": "administrative.country",
            "stylers": [
              { "visibility": "on" }
            ]
        }, {
            "featureType": "administrative.country",
            "elementType": "labels.text.stroke",
            "stylers": [
              { "visibility": "off" }
            ]
        }, {
            "elementType": "labels.text.fill",
            "stylers": [
              { "color": "#343434" }
            ]
        }, {
            "featureType": "administrative.country",
            "elementType": "labels.icon",
            "stylers": [
              { "color": "#ffffff" },
              { "visibility": "off" }
            ]
        }, {
            "featureType": "water",
            "elementType": "labels",
            "stylers": [
              { "visibility": "off" }
            ]
        }, {
            "featureType": "administrative.country",
            "elementType": "geometry.stroke",
            "stylers": [
              { "visibility": "on" },
              { "color": "#FFFFFF" }
            ]
        }
    ]
    return styles;
}
