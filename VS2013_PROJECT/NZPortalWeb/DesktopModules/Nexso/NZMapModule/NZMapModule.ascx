<%@ Control Language="C#" AutoEventWireup="true" CodeFile="NZMapModule.ascx.cs" Inherits="NZMapModule" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Web.Client.ClientResourceManagement" Assembly="DotNetNuke.Web.Client" %>

<dnn:DnnJsInclude ID="GoogleMapsAPÍ" runat="server" FilePath="https://maps.googleapis.com/maps/api/js?key=&sensor=false"></dnn:DnnJsInclude>
<dnn:DnnJsInclude ID="MarkerCluster" runat="server" FilePath="https://google-maps-utility-library-v3.googlecode.com/svn/trunk/markerclustererplus/src/markerclusterer.js"></dnn:DnnJsInclude>

<script src="<%=ControlPath%>js/NXMapModule.js"></script>

<div id="googleMap" style="width: auto; min-height: <%=MinHeight%>px; height: auto; background-color:#F2F2F2;" ></div>
<input type="hidden" id="ExploreMap" value="<%=GetExploreMapButton()%>" style="display:none"/>


<script type="text/javascript">
    //var explore = true;
    var curZoom= <%=CurrentZoom%>;
    var markerCluster;
    var inconUrl = "<%=iconPin%>";
    (function () {

        window.onload = function() {
        
            //document.write('<style> #googleMap {min-height:'+screen.width+'px }</style>'); 
             
            var latlng = new google.maps.LatLng(<%=CurrentLatitude%>, <%=CurrentLongitude%>);
            var styles;
            
            if(curZoom==3){
                
                styles = getStyle();
            }    
            
            var mapOptions = {
                disableDefaultUI: true,
                disableDoubleClickZoom: true,
                zoom: curZoom, //Default zoom level, this changes if you set the fitBounds in creating markers
                center: latlng, //center the map on the position defined by LatLng
                //mapTypeControl: false, //Show / Hide control to change the map type: ROAD, TERRAIN, Satellital
                streetViewControl: false, //Show / Hide icon streeview
                overviewMapControl: false, //Show / Hide control l separate small map bottom right of the screen, by default if not shown and is shown collapsed
                overviewMapControlOptions: { opened: false }, //Expand OverViewMap control
                mapTypeId: google.maps.MapTypeId.ROADMAP,  //default map to show           
                styles: styles,
                scrollwheel: true,
                draggable: true,
                minZoom:1,
                height: 10000,
                width: 10000
                
                
            };
            
            var div = document.getElementById('googleMap');
            var map = new google.maps.Map(div, mapOptions);

            if(curZoom==3){
                
                var control = document.getElementById('ExploreMap');
                if (control != null) {
                    control.type = 'button';
                    control.className = 'buttonMap';
                }
                google.maps.event.addDomListener(control, 'click', function() {
               
                    
                    markerCluster.setZoomOnClick(true);
                    markerCluster.setOptions({disableDoubleClickZoom:true});

                }); 
                control.index = 1;   
                map.controls[google.maps.ControlPosition.TOP_RIGHT].push(control); 
                
            }
            CreateLOcations(map);
            var panelMap = document.getElementById("googleMap");
            var heigth =  screen.height - 195;
            panelMap.style.minHeight = heigth +"px";
           
        };
    })();
    
    function CreateLOcations(map) {
        var queryLenght = 0;
        var arrayMark = <%=Locations%>;
       
        queryLenght = arrayMark.length;
        var locations = new Array(queryLenght);

        for (var x = 0; x < arrayMark.length; x++) {
            locations[x] = [arrayMark[x].name, arrayMark[x].lat, arrayMark[x].lon, arrayMark[x].aditionalInfo];
        }

        var marker;
        var i;
        var infoWindows = [];
        var markers = [];
        
        for (i = 0; i < locations.length; i++) {
            marker = new google.maps.Marker({
                position: new google.maps.LatLng(locations[i][1], locations[i][2]),
                markerIndex: locations[i][3],
                icon:inconUrl,
                map: map      
            });
            
            markers.push(marker);
            infoWindows[i] = new google.maps.InfoWindow();          
            google.maps.event.addListener(marker, 'click', (function (marker, i) {
                return function() {
                    infoWindows[i].setContent(this.markerIndex);
                    infoWindows[i].open(map, marker);
                };
            })(marker, i));
        }
        markerCluster = new MarkerClusterer(map, markers,mcOptions);
        
    }

    mcOptions = {
        styles: [{
            textColor: '#343434',
            textSize: 1,
            height: 53,
            url: inconUrl,
            width: 53
        },
            {
                textColor: '#343434',
                textSize: 1,
                height: 56,
                url: inconUrl,
                width: 56
            },
            {
                textColor: '#343434',
                textSize: 1,
                height: 66,
                url: inconUrl,
                width: 66
            },
            {
                textColor: '#343434',
                textSize: 1,
                height: 78,
                url: inconUrl,
                width: 78
            },
            {
                textColor: '#343434',
                textSize: 1,
                height: 90,
                url: inconUrl,
                width: 90
            }]
    };

    // End Map
    
</script>




