var geocoder;
var positions;
var marker;
var iconGen = "http://mapicons.nicolasmollet.com/wp-content/uploads/mapicons/shape-default/color-ff8a22/shapecolor-color/shadow-1/border-dark/symbolstyle-white/symbolshadowstyle-dark/gradient-no/orienteering.png";
var arrayMarkers;
var infowindow;

////Validate Location implementation
var iconGenTestLocation = "http://icons.iconarchive.com/icons/icons-land/vista-map-markers/32/Map-Marker-Marker-Outside-Azure-icon.png";
var typeTestLocation = "testLocation";
///// Validate type Org
var iconGenOrg = "http://icons.iconarchive.com/icons/icons-land/vista-map-markers/32/Map-Marker-Marker-Outside-Azure-icon.png";
var swActive = true;
var swZoom = false;
var OrganizationName;
var typeOrg = "organization"
var typeLocation;
var iconGenAux;
var profileOrg;

//objects

var txtBoxCityStateCountry;
var txtBoxAddress;
var btnGeocode;
var hdVal;
var map;

var viewInEditMode;
var addressRequired;
var multiSelect;
var addressPlaceHolder;
var cscPlaceHolder;
var locationsPanel;
var locationsList;
var emptyMessage;
var bounds;

function initializemap(mapBox, textBox, textBoxAddress, buttonGeocode, hiddenVal, clientId) {

    if (mapBox) {

        geocoder = new google.maps.Geocoder();
        bounds = new google.maps.LatLngBounds();
        txtBoxCityStateCountry = textBox;
        txtBoxAddress = textBoxAddress;
        btnGeocode = buttonGeocode;
        hdVal = hiddenVal;

        iconGenOrg = this['iconGenOrg' + clientId];
        iconGenTestLocation = this['iconGenTestLocation' + clientId];
        profileOrg = this['profileOrg' + clientId];
        organizationName = this['orgName' + clientId];
        viewInEditMode = this['viewInEditModeIni' + clientId];
        multiSelect = this['multiSelectIni' + clientId];
        addressPlaceHolder = this['addressPlaceHolderIni' + clientId];
        cscPlaceHolder = this['cscPlaceHolderIni' + clientId];
        addressRequired = this['addressRequiredIni' + clientId];
        iconGen = this['iconGenIni' + clientId];
        locationsPanel = $('#locationsPanel' + clientId);
        locationsList = $('#locationsList' + clientId);
        emptyMessage = $('#emptyMessage' + clientId);
        iconGenAux = iconGen;
        locationsList.html('');
        if (viewInEditMode) {
            $(textBox).show();
            $(txtBoxAddress).show();
            $(btnGeocode).show();


        } else {
            $(textBox).hide();
            $(txtBoxAddress).hide();
            $(btnGeocode).hide();
        }
        if (multiSelect) {
            $(locationsPanel).show();
        } else {
            $(locationsPanel).hide();
        }

        if (addressRequired) {
            $(txtBoxAddress).show();
        } else {
            $(txtBoxAddress).hide();
        }

        $(txtBoxAddress).attr("placeholder", addressPlaceHolder);
        $(txtBoxCityStateCountry).attr("placeholder", cscPlaceHolder);

        positions = [];

        var mapOptions = {
            center: new google.maps.LatLng(10.900385, -76.996295),
            zoom: 2
        };


        map = new google.maps.Map(mapBox, mapOptions);

        // map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);

        if (!addressRequired) {
            infowindow = new google.maps.InfoWindow();
        }
        marker = new google.maps.Marker({
            map: map
        });

        paintPoints();

        if (txtBoxCityStateCountry) {


            var autocomplete = new google.maps.places.Autocomplete(txtBoxCityStateCountry, {
                types: ['(cities)']
            });
            autocomplete.bindTo('bounds', map);
            google.maps.event.addListener(autocomplete, 'place_changed', function () {

                var place = autocomplete.getPlace();
                if (!place.geometry) {
                    return;
                }

                var standardObject = getJsonObjecthFromGooglePosition(place, $(txtBoxCityStateCountry).val(), $(txtBoxAddress).val());
                if (!multiSelect) {
                    if ($(txtBoxAddress).val() == '') {

                        infowindow.close();
                        marker.setVisible(false);

                        // If the place has a geometry, then present it on a map.
                        if (place.geometry.viewport) {
                            map.fitBounds(place.geometry.viewport);
                        } else {
                            map.setCenter(place.geometry.location);
                            map.setZoom(17); // Why 17? Because it looks good.
                        }

                        formatMarkerFromStandardObject(standardObject);

                        if (addressRequired) {
                            $(txtBoxAddress).show();
                            $(btnGeocode).show();
                        } else {
                            $(txtBoxAddress).hide();
                            $(btnGeocode).hide();
                        }

                    } else {
                        geocodeAddress();
                    }
                }

            });


        }

        // Sets a listener on a radio button to change the filter type on Places
        // Autocomplete.


        // Sets a listener on a radio button to change the filter type on Places
        // Autocomplete.
    }
}


function paintPoints() {

    var positionsTmp = JSON.parse($(hdVal).val());
    if (positionsTmp.length == 1) {
        swZoom = true;
    }
    if (positionsTmp.length > 0) {
        for (var ii = 0; ii < positionsTmp.length; ii++) {

            formatMarkerFromStandardObject(positionsTmp[ii]);
        }

    } else {
        locationsPanel.hide();
        emptyMessage.show();
    }
    if (positionsTmp.length == 1) {
        if (positionsTmp[0].type == typeOrg) {
            swActive = false;
            locationsPanel.hide();
            emptyMessage.show();
        }
    }
}


function geocodeAddress() {


    var cityStateCountry = $(txtBoxCityStateCountry).val();
    var address = $(txtBoxAddress).val();
    geocoder.geocode({ 'address': address + ' ' + cityStateCountry }, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            var standardObject = getJsonObjecthFromGooglePosition(results[0], cityStateCountry, address);
            formatMarkerFromStandardObject(standardObject);

        } else {
            //  alert('Geocode was not successful for the following reason: ' + status);
        }
    });
}

function formatMarkerFromStandardObject(standardObject) {

    typeLocation = standardObject.type;
    if (standardObject.latitude == 0 && standardObject.longitude == 0) {

        var cityStateCountry = standardObject.city + ' ' + standardObject.state + ' - ' + standardObject.country;
        geocoder.geocode({ 'address': standardObject.inputAddress + ' ' + cityStateCountry }, function (results, status) {
            if (status == google.maps.GeocoderStatus.OK) {

                var standardObjectTmp = getJsonObjecthFromGooglePosition(results[0], cityStateCountry, standardObject.inputAddress, standardObject.type);
                formatMarkerFromStandardObject(standardObjectTmp);

            } else {
                //  alert('Geocode was not successful for the following reason: ' + status);
            }
        });

    } else {
        var latlng = new google.maps.LatLng(standardObject.latitude, standardObject.longitude);

        var marker1;

        if (multiSelect) {

            marker1 = new google.maps.Marker({
                map: map
            });
            var sw = false;
            for (i = 0; i < positions.length; i++) {
                if (positions[i].country == standardObject.country && positions[i].city == standardObject.city && positions[i].state == standardObject.state) {
                    sw = true;
                }
            }
            if (!sw) {
                positions.push(standardObject);
            }
            marker1.set("idList", positions.length - 1);

        } else {
            marker1 = marker;
            positions[0] = standardObject;

        }

        var contentInfoWindows;
        var x;
        var y;
        var x1;
        var y1;
        if (typeLocation == typeOrg) {
            iconGen = iconGenOrg;
            contentInfoWindows = '<div><div><strong><a target="_blank" href=\"' + profileOrg + '\">' + organizationName.toUpperCase() + '</a></strong><br><br>' + standardObject.inputAddress + '<br>' + standardObject.city + ' ' + standardObject.state + ', ' + standardObject.country + '<br><br>';
            x = 20; y = 26; x1 = 10; y1 = 25;
        }
        else {

            if (typeLocation == typeTestLocation) {
                iconGen = iconGenTestLocation;
                x = 26; y = 26; x1 = 13; y1 = 25;
            } else {
                iconGen = iconGenAux;
                x = 35; y = 35; x1 = 17; y1 = 34;
            }
            if (!addressRequired) {
                contentInfoWindows = '<div><div><strong>' + standardObject.city + ' ' + standardObject.state + ', ' + standardObject.country + '</strong><br>' + standardObject.inputAddress + '<br><br>';

            }
        }
       
        $(hdVal).val(JSON.stringify(positions));

        marker1.setIcon(/** @type {google.maps.Icon} */({
            url: iconGen,
            size: new google.maps.Size(x, y),
            origin: new google.maps.Point(0, 0),
            anchor: new google.maps.Point(x1, y1),
            scaledSize: new google.maps.Size(x, y)
        }));

        map.setCenter(latlng);
        marker1.setPosition(latlng);
        marker1.setVisible(true);


        if (!addressRequired && viewInEditMode) {

            contentInfoWindows = contentInfoWindows + '<div><button name="remove-marker" class="remove-marker" title="Remove Marker">Remove Marker</button></div>';

        }

        if (multiSelect) {
            if (swActive) {
                locationsPanel.show();
                emptyMessage.hide();
            }
            var list;
            var list2;
            var sw = false;
            if (typeLocation == typeOrg) {
                sw = true;
            } else {
                $.each(locationsList, function (key, value) {

                    list = $(value).text().split(".");
                    for (i = 0; i < list.length; i++) {
                        var newLocalition = standardObject.city + ' ' + standardObject.state + ', ' + standardObject.country + '.'
                        var newLocalition2 = standardObject.city + ' ' + standardObject.state + ', ' + '.';
                        if (list[i] + '.' == newLocalition || list[i] + '.' == newLocalition2) {
                            sw = true;
                        }
                    }

                });
            }
            if (!sw) {
                $(locationsList).append('<li id="ltl' + marker1.get("idList") + '">' + standardObject.city + ' ' + standardObject.state + ', ' + standardObject.country + '.' + '</li>');
            }


        }
        if (!addressRequired) {
            contentInfoWindows = contentInfoWindows + ' </div>';
            contentInfoWindows = $(contentInfoWindows);
        }
        if (typeLocation != typeOrg && typeLocation != typeTestLocation && !addressRequired) {
            infowindow.setContent(contentInfoWindows[0]);
            infowindow.open(map, marker1);
        }

        google.maps.event.addListener(marker1, 'click', function () {
            infowindow.close(map,marker1);
            infowindow = new google.maps.InfoWindow({
                content: contentInfoWindows[0]
            });
            infowindow.open(map, marker1);
        });
        if (!addressRequired) {
            var removeBtn = contentInfoWindows.find('button.remove-marker')[0];
            if (removeBtn != null) {
                google.maps.event.addDomListener(removeBtn, "click", function (event) {
                    marker1.setMap(null);
                    var idlist = marker1.get("idList");
                    positions.splice(idlist, 1);
                    $('#ltl' + idlist).remove();
                    $(hdVal).val(JSON.stringify(positions));
                });

            }
        }
        if (txtBoxCityStateCountry) {

            $(txtBoxCityStateCountry).val(standardObject.city + ' ' + standardObject.state + ', ' + standardObject.country);

            if (addressRequired) {
                $(txtBoxAddress).show();
                $(btnGeocode).show();

            }

            $(txtBoxAddress).val(standardObject.inputAddress);

        }

        if (!swZoom) {
            bounds.extend(marker1.position);
            map.fitBounds(bounds);
            var zoom = map.getZoom();
            map.setZoom(zoom > 4 ? 4 : zoom);
        } else {
            if (viewInEditMode && addressRequired) {
                map.setZoom(17);
            } else {
                map.setZoom(4);
            }
        }
    }
}


function getJsonObjecthFromGooglePosition(place, inputCityStateCountry, inputAddress, locationType) {
    if (inputCityStateCountry != "null null - ") {
        if (place.address_components) {
            city = state = locality = administrative_area_level_1 = administrative_area_level_2 = administrative_area_level_3 = country = countryShort = formatted_address = route = postal_code = street_number = '';

            for (var index = 0; index < place.address_components.length; index++) {
                if (place.address_components[index].types[0] == "country") {
                    country = place.address_components[index].long_name;
                    countryShort = place.address_components[index].short_name;
                }
                if (place.address_components[index].types[0] == "administrative_area_level_1") {
                    administrative_area_level_1 = place.address_components[index].long_name;
                    state = administrative_area_level_1;
                }
                if (place.address_components[index].types[0] == "administrative_area_level_2") {
                    administrative_area_level_2 = place.address_components[index].long_name;
                    city = administrative_area_level_2;
                }
                if (place.address_components[index].types[0] == "administrative_area_level_3")
                    administrative_area_level_3 = place.address_components[index].long_name;
                if (place.address_components[index].types[0] == "locality") {
                    locality = place.address_components[index].long_name;
                    if (city == '') {
                        city = locality;
                    }
                }
                if (place.address_components[index].types[0] == "street_number")
                    street_number = place.address_components[index].long_name;
                if (place.address_components[index].types[0] == "route")
                    route = place.address_components[index].long_name;
                if (place.address_components[index].types[0] == "postal_code")
                    postal_code = place.address_components[index].long_name;

            }
            formatted_address = place.formatted_address;
            latitude = place.geometry.location.lat();
            longitude = place.geometry.location.lng();
            icon = iconGen;

        }

        return_ = {
            "country": country,
            "countryShort": countryShort,
            "administrative_area_level_1": administrative_area_level_1,
            "administrative_area_level_2": administrative_area_level_2,
            "administrative_area_level_3": administrative_area_level_3,
            "locality": locality,
            "street_number": street_number,
            "route": route,
            "postal_code": postal_code,
            "formatted_address": formatted_address,
            "latitude": latitude,
            "longitude": longitude,
            "icon": iconGen,
            "inputCityStateCountry": inputCityStateCountry,
            "inputAddress": inputAddress,
            "city": city,
            "state": state,
            "type": locationType

        };

        return return_;

    }

}