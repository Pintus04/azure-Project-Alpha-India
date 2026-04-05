param location string = resourceGroup().location
param logicAppName string
param recurrenceTimeZone string = 'India Standard Time'
//param recurrenceHour int
//param recurrenceMinute int
param recurrenceHours array
param recurrenceMinutes array
param urlScheduler string

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  location: location
  properties: {
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      triggers: {
        Recurrence: {
          type: 'Recurrence'
          recurrence: {
            frequency: 'Day'
            interval: 1
            timeZone: recurrenceTimeZone
            schedule: {
              //hours: [recurrenceHour]
              //minutes: [recurrenceMinute]
              hours: recurrenceHours
              minutes: recurrenceMinutes
            }
          }
        }
      }
      actions: {
        HTTP_Request: {
          type: 'Http'
          inputs: {
            method: 'GET'
            uri: urlScheduler
            headers: {
              accept: '*/*'
            }
          }
        }
      }
    }
    parameters: {}
  }
}
