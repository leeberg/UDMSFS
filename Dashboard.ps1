New-UDDashboard -Title "Flight Buddy Development!" -Content {

    $Cache:FollowAircraft = $true
    $Cache:MapZoom = 10
    $Cache:MarkerCount = 0
    $Cache:AirplaneIcon = New-UDMapIcon -Url 'https://www.flaticon.com/svg/static/icons/png/32/633/633800.png' -Height 32 -Width 32
    $Cache:TravelDotIcon = New-UDMapIcon -Url 'https://www.flaticon.com/svg/static/icons/png/32/401/401096.png' -Height 8 -Width 8

    $Cache:AircraftLatitude = ""
    $Cache:AircraftLongitude = ""

    #Stats todo

    # PLANE ALT ABOVE GROUND
    # TOTAL WEIGHT
    # TURN INDICATOR RATE
    # MAGNETIC COMPASS
    # ABSOLUTE TIME
    # ZULU TIME
    # FUEL TOTAL QUANTITY
    # ATC TYPE	String64	N	Responded		
    # ATC MODEL	String64	N	Responded		
    # ATC ID	String64	Y	Responded	fail	
    # ATC AIRLINE	String64	Y	Responded	fail	
    # ATC FLIGHT NUMBER	String8	Y	Responded	fail	
    #TITLE



    #https://www.flaticon.com/svg/static/icons/png/32/633/633800.png
    #
    New-UDGrid -Container -Content {

        New-UDGrid -Item -ExtraSmallSize 6 -Content {
            New-UDCard -Title 'Universal Dashboard + Microsoft Flight Simulator' -Content {
                

                New-UDDynamic -Id 'FlightStats' -Content {
                    
                    #$ATC_TYPE = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/ATC_TYPE/get').Content
                    $ATC_MODEL = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/ATC_MODEL/get').Content
                    $ATC_ID = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/ATC_ID/get').Content
                    $ATC_AIRLINE = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/ATC_AIRLINE/get').Content
                    #$ATC_FLIGHT_NUMBER = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/ATC_FLIGHT_NUMBER/get').Content
                    $FUEL_TOTAL_QUANTITY = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/FUEL_TOTAL_QUANTITY/get').Content
                    $FUEL_TOTAL_QUANTITY = $FUEL_TOTAL_QUANTITY.SubString(0,$FUEL_TOTAL_QUANTITY.IndexOf(".")+2)

                    $PlaneID = ($ATC_ID + " " + $ATC_AIRLINE)

                    $AircraftModel = "Unknown"
                    
                    switch ($ATC_MODEL) {
                        '"TT:ATCCOM.ATC_NAME_CUBCRAFTERS.0.text"' { $AircraftModel = "CubCrafters Carbon Cub" }
                        Default { $AircraftModel = "Unknown" }
                    }

                    New-UDPaper -Elevation 0 -Content {New-UDTypography -Text "This is some content"}
                    New-UDPaper -Elevation 0 -Content {New-UDTypography -Text "Aircraft: $AircraftModel" }
                    New-UDPaper -Elevation 0 -Content {New-UDTypography -Text "Aircraft ID: $PlaneID" }
                    New-UDPaper -Elevation 0 -Content {New-UDTypography -Text "Total Fuel: $FUEL_TOTAL_QUANTITY"}

                    
                } -AutoRefresh -AutoRefreshInterval 60


            }
        }
    
        New-UDGrid -Item -ExtraSmallSize 6 -Content {
            New-UDCard -Title 'Autopilot Controls' -Content {
                
                New-UDTypography -Text "Autopilot Master" 
                New-UDSwitch -Id switchAutoMaster -OnChange { 
                    Invoke-WebRequest -Method Post -Uri 'http://localhost:5001/event/AP_MASTER/trigger'
                    Show-UDToast -Message 'AutoPilot Master Toggle'
                }

                New-UDTypography -Text "Heading Mode"  
                New-UDSwitch -Id switchAutoHeading -OnChange {
                    Invoke-WebRequest -Method Post -Uri 'http://localhost:5001/event/AP_HDG_HOLD/trigger'
                    Show-UDToast -Message 'AutoPilot Heading Toggle'
                }

                New-UDTypography -Text "Vertical Speed Mode" 
                New-UDSwitch -Id switchAutoVertical -OnChange {
                    Invoke-WebRequest -Method Post -Uri 'http://localhost:5001/event/AP_PANEL_VS_SET/trigger'
                    
                    #Set
                    #AP_ALT_VAR_SET_ENGLISH
                    #AP_VS_VAR_SET_ENGLISH

                    Show-UDToast -Message 'AutoPilot Vertical Speed Toggle'
                    Show-UDToast -Message '/event/AUTOPILOT_HEADING_LOCK/trigger'
                }
            }
        }
    


        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content {     
                New-UDDynamic -Id 'AirspeedDynamic' -Content {
                    $AIRSPEED_INDICATED = '102.50'
                    $AIRSPEED_INDICATED = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/AIRSPEED_INDICATED/get').Content
                    $AIRSPEED_INDICATED = $AIRSPEED_INDICATED.SubString(0,$AIRSPEED_INDICATED.IndexOf("."))
                    New-UDTypography -Text "Airspeed: $AIRSPEED_INDICATED Knots"
                } -AutoRefresh -AutoRefreshInterval 5 
            } -Elevation 2
        }

        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content {     
                New-UDDynamic -Id 'AltitudeDynamic' -Content {
                    $PLANE_ALTITUDE = '5002.2355345435435'
                    $PLANE_ALTITUDE = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/PLANE_ALTITUDE/get').Content
                    $PLANE_ALTITUDE = $PLANE_ALTITUDE.SubString(0,$PLANE_ALTITUDE.IndexOf("."))
                    New-UDTypography -Text "Altitude: $PLANE_ALTITUDE Feet"
                } -AutoRefresh -AutoRefreshInterval 5 
            } -Elevation 2
        }


        
        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content {     
                New-UDDynamic -Id 'VertSpeedDynamic' -Content {
                    $VERTICAL_SPEED = '52.2355345435435'
                    $VERTICAL_SPEED = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/VERTICAL_SPEED/get').Content
                    $VERTICAL_SPEED = $VERTICAL_SPEED.SubString(0,$VERTICAL_SPEED.IndexOf("."))
                    New-UDTypography -Text "Vertical Speed: $VERTICAL_SPEED FPM"
                } -AutoRefresh -AutoRefreshInterval 5 
            } -Elevation 2
        }

        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content {     
                New-UDDynamic -Id 'HeadingDynamic' -Content {
                    $Heading = '198.2355345435435'
                    $Heading = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/MAGNETIC_COMPASS/get').Content
                    $Heading = $Heading.SubString(0,$Heading.IndexOf("."))

                    New-UDTypography -Text "Heading: $Heading Degrees"
                } -AutoRefresh -AutoRefreshInterval 5 
            } -Elevation 2
        }

        New-UDGrid -Item -ExtraSmallSize 12 -Content {

            New-UDPaper -Content {
              
                    New-UDMap -Id 'flightMap' -Endpoint {
                    
                        New-UDMapLayerControl -Id 'layercontrol' -Content {
                            
                            New-UDMapBaseLayer -Name "Mapnik" -Content {
                                New-UDMapRasterLayer -TileServer 'https://tiles.wmflabs.org/hikebike/{z}/{x}/{y}.png'
                                #New-UDMapRasterLayer -TileServer 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png' 
                            } -Checked

                            New-UDMapOverlay -Name "Markers" -Content {
                                New-UDMapFeatureGroup -Id 'Feature-Group' -Content {
                                
                                }
                            } -Checked

                        }


                    } -Height '100ch' -Zoom $Cache:MapZoom -Animate
            
                    New-UDDynamic -Id 'MapMarkerDynamic' -Content {

                        Add-UDElement -ParentId 'Feature-Group' -Content {
                          
                            $Latitude = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/PLANE_LATITUDE/get').Content.SubString(0,8)
                            $Longitude = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/PLANE_LONGITUDE/get').Content.SubString(0,8)
                              
                            Remove-UDElement -Id ($Cache:MarkerCount)

                            $Cache:MarkerCount += 1
                            New-UDMapMarker -Id ($Cache:MarkerCount)  -Icon $Cache:AirplaneIcon -Latitude $Latitude -Longitude $Longitude -Popup (New-UDMapPopup -Content { New-UDHeading -Text "$Latitude  -  $Longitude" })
                            
                            New-UDMapMarker -Icon $Cache:TravelDotIcon -Latitude $Latitude -Longitude $Longitude

                            if($Cache:FollowAircraft -eq $true)
                            {
                                
                                Set-UDElement -Id 'flightMap' -Properties  @{
                                    latitude = $Latitude
                                    longitude = $Longitude
                                    zoom = $Cache:MapZoom
                                }
                                
                            }
                        }

                    } -AutoRefresh -AutoRefreshInterval 10
   
            } -Elevation 2

        }
    }
}

