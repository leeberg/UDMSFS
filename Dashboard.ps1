New-UDDashboard -Title "Flight Buddy Development!" -Content {

    $Cache:FollowAircraft = $true
    $Cache:MapZoom = 10
    $Cache:MarkerCount = 0
    $Cache:AirplaneIcon = New-UDMapIcon -Url 'https://www.flaticon.com/svg/static/icons/png/32/633/633800.png' -Height 32 -Width 32
    $Cache:TravelDotIcon = New-UDMapIcon -Url 'https://www.flaticon.com/svg/static/icons/png/32/401/401096.png' -Height 8 -Width 8


    $Cache:LastLong = "Start"
    $Cache:LastLat = "Start"



    # Aircraft Flight Data
    $Cache:AircraftLatitude = ""
    $Cache:AircraftLongitude = ""
    $Cache:AircraftAirSpeed = ""
    $Cache:AircraftAltitude = ""
    $Cache:AircraftVerticalSpeed = ""
    $Cache:AircraftHeading = ""
        

    # Aircraft Information
    $Cache:ATC_MODEL = ""
    $Cache:ATC_ID = ""
    $Cache:ATC_AIRLINE = ""

    # Aircraft Stats
    $Cache:FUEL_TOTAL_QUANTITY = ""
    

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


    New-UDDynamic -Id 'GetAircraftFlightInformation' -Content {
    
        $AircraftData = (Invoke-WebRequest -Method Get -Uri 'http://localhost:5001/datapoint/aircraftflightdata/get').Content
        
        $AircraftDataValues = $AircraftData.Split(',').Replace('"','')

        $Cache:AircraftLatitude = $AircraftDataValues[1]
        $Cache:AircraftLongitude = $AircraftDataValues[2]
        $Cache:AircraftAirSpeed = $AircraftDataValues[3]
        $Cache:AircraftAltitude = $AircraftDataValues[4]
        $Cache:AircraftVerticalSpeed = $AircraftDataValues[5]
        $Cache:AircraftHeading = $AircraftDataValues[5]

    } -AutoRefresh -AutoRefreshInterval 5 



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

                    if($Cache:AircraftAirSpeed -ne '')
                    {
                        $AircraftAirSpeed = $Cache:AircraftAirSpeed.SubString(0,$Cache:AircraftAirSpeed.IndexOf("."))
                        New-UDTypography -Text "Airspeed: $AircraftAirSpeed Knots"
                    }
                    
                } -AutoRefresh -AutoRefreshInterval 1
            } -Elevation 2
        }

        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content {     
                New-UDDynamic -Id 'AltitudeDynamic' -Content {

                    if($Cache:AircraftAltitude -ne '')
                    {
                        $AircraftAltitude = $Cache:AircraftAltitude.SubString(0,$Cache:AircraftAltitude.IndexOf("."))
                        New-UDTypography -Text "Altitude: $AircraftAltitude Feet"
                    }
                } -AutoRefresh -AutoRefreshInterval 1
            } -Elevation 2
        }


        
        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content {     
                New-UDDynamic -Id 'VertSpeedDynamic' -Content {
                    if($Cache:AircraftVerticalSpeed -ne '')
                    {
                        $AircraftVerticalSpeed = $Cache:AircraftVerticalSpeed.SubString(0,$Cache:AircraftVerticalSpeed.IndexOf("."))
                        New-UDTypography -Text "Vertical Speed: $AircraftVerticalSpeed FPM"
                    }
                } -AutoRefresh -AutoRefreshInterval 1
            } -Elevation 2
        }

        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content {     
                New-UDDynamic -Id 'HeadingDynamic' -Content {
                    if($Cache:AircraftHeading -ne '')
                    {
                        $AircraftHeading = $Cache:AircraftHeading
                        $AircraftHeading = $Heading.SubString(0,$Heading.IndexOf("."))
                        New-UDTypography -Text "Heading: $AircraftHeading Degrees"
                    }                    
                } -AutoRefresh -AutoRefreshInterval 1
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

                            Remove-UDElement -Id ($Cache:MarkerCount)

                            $Cache:MarkerCount += 1
                            New-UDMapMarker -Id ($Cache:MarkerCount)  -Icon $Cache:AirplaneIcon -Latitude $Cache:AircraftLatitude -Longitude $Cache:AircraftLongitude -Popup (New-UDMapPopup -Content { New-UDHeading -Text "$Cache:AircraftLatitude  -  $Cache:AircraftLongitude" })
                            
                            if($Cache:LastLat -ne "Start" -and $Cache:LastLong -ne "Start")
                            {
                                New-UDMapMarker -Icon $Cache:TravelDotIcon -Latitude $Cache:LastLat -Longitude $Cache:LastLong
                            }
                            
                            $Cache:LastLong = $Cache:AircraftLongitude
                            $Cache:LastLat = $Cache:AircraftLatitude

                            if($Cache:FollowAircraft -eq $true)
                            {
                                <# Bug - pending new version
                                Set-UDElement -Id 'flightMap' -Properties  @{
                                    latitude = $Cache:AircraftLatitude
                                    longitude = $Cache:AircraftLongitude
                                    zoom = $Cache:MapZoom
                                }
                                #>
                            }
                        }

                    } -AutoRefresh -AutoRefreshInterval 10
   
            } -Elevation 2

        }
    }
}