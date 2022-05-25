//
//  MergeDates.swift
//  datepicker
//
//  Created by Андрей Королев on 25.05.2022.
//

import Foundation

//func for date merge
//get year, month, day from first date
//and hour, minute, second from second date

func mergeDates(firstDate: Date, secondDate: Date) -> Date {
    let calendar = Calendar.current
            
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: firstDate)
    let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: secondDate)

    var mergedComponments = DateComponents()
    mergedComponments.year = dateComponents.year
    mergedComponments.month = dateComponents.month
    mergedComponments.day = dateComponents.day
    mergedComponments.hour = timeComponents.hour
    mergedComponments.minute = timeComponents.minute
    mergedComponments.second = timeComponents.second
    
    return calendar.date(from: mergedComponments)!
}
