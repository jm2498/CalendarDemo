//
//  ViewController.swift
//  CVCalendar Demo
//
//  Created by Мак-ПК on 1/3/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Properties
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var eventTitle: UITextField!
	@IBOutlet weak var eventDuration: UITextField!
	@IBOutlet weak var workLoadBar: UISlider!
	@IBOutlet weak var timeLineBar: UISlider!
	@IBOutlet weak var endDate: UIDatePicker!
	@IBOutlet weak var eventTabel: UITableView!
	@IBOutlet weak var endDateDetail: UILabel!
    
    
    var shouldShowDaysOut = false
    var animationFinished = true
    
    let eventStore = EKEventStore()
	let dateFormatter = NSDateFormatter()
    var selectedDay: CVCalendarDayView!
	var eventDays = [CVCalendarDayView]()
	var workHours = [Float]()
	var today: CVCalendarDayView!
	var predict: NSPredicate!
	var numOfDays: Int!
	var numOfWeeks: Int!
	var totalHoursToWork: Float!
    
    var Time = 10
    var Timer = NSTimer()
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        monthLabel.text = CVDate(date: NSDate()).globalDescription
        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            self.eventStore.requestAccessToEntityType(.Event, completion: {granted, error in})
        }
        
        self.selectedDay = calendarView.coordinator.selectedDayView
		today = calendarView.coordinator.selectedDayView
        
         Timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("Notification"), userInfo: nil, repeats: true)
		
    }
    
    //Notification func
    func Notification(){
        Time -= 1
        
        if(Time == 0){
            
            var Notification = UILocalNotification()
            
            
            Notification.alertAction = "Enter App"
            Notification.alertBody = "Push Event list here"
            
            Notification.fireDate = NSDate(timeIntervalSinceNow: 0)
            
            UIApplication.sharedApplication().scheduleLocalNotification(Notification)
            
            Timer.invalidate()
            
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
		view.endEditing(true)
		super.touchesBegan(touches, withEvent: event)
	}
	
	func clearEventInfo() {
		eventTitle.text?.removeAll()
		workLoadBar.value = 50.0
		timeLineBar.value = 50.0
		eventDuration.text?.removeAll()
		endDate.date = NSDate()
	}
	
	func setupViews() {
		addButton.hidden = !addButton.hidden
		todayButton.hidden = !todayButton.hidden
		eventTabel.hidden = !eventTabel.hidden
		doneButton.hidden = !doneButton.hidden
		cancelButton.hidden = !cancelButton.hidden
		eventView.hidden = !eventView.hidden
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.selectedDay.eventList.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("EventTableViewCell", forIndexPath: indexPath)
		
		let event = self.selectedDay.eventList[indexPath.row]
		self.dateFormatter.dateFormat = "HH:mm"
		let start = self.dateFormatter.stringFromDate(event.startDate)
		let end = self.dateFormatter.stringFromDate(event.endDate)
		let title = event.title
		cell.textLabel!.text = "\(start) - \(end) : \(title)"
		
		return cell
	}
	
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if (editingStyle == UITableViewCellEditingStyle.Delete) {
			// handle delete (by removing the data from your array and updating the tableview)
		}
	}
	
}

// MARK: - CVCalendarViewDelegate & CVCalendarMenuViewDelegate

extension ViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    
    func shouldShowWeekdaysOut() -> Bool {
        return self.shouldShowDaysOut
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    func didSelectDayView(dayView: CVCalendarDayView) {
        self.selectedDay = dayView
		eventTabel.reloadData()
        print("\(dayView.date.commonDescription) is selected!")
//		predict = eventStore.predicateForEventsWithStartDate(NSDate(), endDate: NSDate(), calendars: nil)
//		let events = eventStore.eventsMatchingPredicate(predict)
//		print(events[0])
    }
    
    func presentedDateUpdated(date: CVDate) {
        if monthLabel.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.text = updatedMonthLabel.text
                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
//    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
//        let day = dayView.date.day
//        let randomDay = Int(arc4random_uniform(31))
//        if day == randomDay {
//            return true
//        }
//        
//        return false
//    }
	
//    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
//        let day = dayView.date.day
//        
//        let red = CGFloat(arc4random_uniform(600) / 255)
//        let green = CGFloat(arc4random_uniform(600) / 255)
//        let blue = CGFloat(arc4random_uniform(600) / 255)
//        
//        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
//
//        let numberOfDots = Int(arc4random_uniform(3) + 1)
//        switch(numberOfDots) {
//        case 2:
//            return [color, color]
//        case 3:
//            return [color, color, color]
//        default:
//            return [color] // return 1 dot
//        }
//    }
	
//    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
//        return true
//    }

    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 6
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }

}

// MARK: - CVCalendarViewDelegate
/*
extension ViewController: CVCalendarViewDelegate {
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        let π = M_PI
        
        let ringSpacing: CGFloat = 3.0
        let ringInsetWidth: CGFloat = 1.0
        let ringVerticalOffset: CGFloat = 1.0
        var ringLayer: CAShapeLayer!
        let ringLineWidth: CGFloat = 4.0
        let ringLineColour: UIColor = .blueColor()
        
        let newView = UIView(frame: dayView.bounds)
        
        let diameter: CGFloat = (newView.bounds.width) - ringSpacing
        let radius: CGFloat = diameter / 2.0
        
        let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
        
        ringLayer = CAShapeLayer()
        newView.layer.addSublayer(ringLayer)
        
        ringLayer.fillColor = nil
        ringLayer.lineWidth = ringLineWidth
        ringLayer.strokeColor = ringLineColour.CGColor
        
        let ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
        let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
        let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
        let startAngle: CGFloat = CGFloat(-π/2.0)
        let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
        let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        ringLayer.path = ringPath.CGPath
        ringLayer.frame = newView.layer.bounds
        
        return newView
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (Int(arc4random_uniform(3)) == 1) {
            return true
        }
        
        return false
    }
}
*/

// MARK: - CVCalendarViewAppearanceDelegate

extension ViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - IB Actions

extension ViewController {
    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
    /// Switch to WeekView mode.
//    @IBAction func toWeekView(sender: AnyObject) {
//        calendarView.changeMode(.WeekView)
//    }
//    
//    /// Switch to MonthView mode.
//    @IBAction func toMonthView(sender: AnyObject) {
//        calendarView.changeMode(.MonthView)
//    }
//    
//    @IBAction func loadPrevious(sender: AnyObject) {
//        calendarView.loadPreviousView()
//    }
//    
//    
//    @IBAction func loadNext(sender: AnyObject) {
//        calendarView.loadNextView()
//    }
	
    @IBAction func setEventInfo() {
        self.setupViews()
    }
    
    @IBAction func cancelEvent() {
        self.setupViews()
		self.clearEventInfo()
		
    }
    
    @IBAction func addEvent() {
        self.setupViews()
		let event = EKEvent(eventStore: self.eventStore)
		if (eventTitle.text! == "") {
			event.title = "New Event"
		} else {
			event.title = eventTitle.text!
		}
		event.startDate = NSDate()
		event.endDate = endDate.date
		today.eventList.append(event)
		today.setupDotMarker()
//		event.calendar = eventStore.defaultCalendarForNewEvents
//		do {
//			try eventStore.saveEvent(event, span: .ThisEvent)
//		} catch {
//			print("Bad thing happened")
//		}
		eventTabel.reloadData()
		
    }
	
	@IBAction func changeWorkLoad(sender: UISlider) {
		self.workHours.removeAll()
		let day = ceil(self.timeLineBar.value)
		let up = (sender.value * Float(self.numOfDays) - self.totalHoursToWork) * 2.0
		let bot1 = day * (day - 1)
		let bot2 = (Float(self.numOfDays) - day + 1.0) * (Float(self.numOfDays) - day)
		let delta = up / (bot1 + bot2)
		print(sender.value)
		print(self.timeLineBar.value)
		print(day)
		for index in 0...(eventDays.count-1) {
			if (index <= Int(day)-1) {
				let workload = sender.value-Float(Int(day)-(index+1)) * delta
				eventDays[index].setupWorkLoadMarker(CGFloat(workload*5.0))
				workHours.append(workload * 5)
			}
			else {
				let workload = sender.value-Float(index+1-Int(day)) * delta
				eventDays[index].setupWorkLoadMarker(CGFloat(workload*5.0))
				workHours.append(workload * 5)
			}
		}
	}
	
	@IBAction func changeTimeLine(sender: UISlider) {
		
	}
	
	@IBAction func changeEndDate(sender: UIDatePicker) {
		self.dateFormatter.dateFormat = "MM-dd"
		let todayDate = self.dateFormatter.stringFromDate(NSDate())
		let datePickerDate = self.dateFormatter.stringFromDate(sender.date)
		if (todayDate != datePickerDate) {
			self.eventDays.removeAll()
			workLoadBar.enabled = true
			timeLineBar.enabled = true
			let start = today.date.getDay
			self.dateFormatter.dateFormat = "d"
			let end = Int(self.dateFormatter.stringFromDate(sender.date))!
			self.numOfDays = end - start + 1
			self.numOfWeeks = (self.numOfDays-(7-today.weekdayIndex+1))/7
			if ((self.numOfDays-(7-today.weekdayIndex+1))%7 > 0) {
				self.numOfWeeks = self.numOfWeeks + 1
			}
			self.totalHoursToWork = Float(self.eventDuration.text!)
			self.timeLineBar.maximumValue = Float(self.numOfDays + 1)
			self.timeLineBar.value = Float(self.numOfDays) / 2.0
			self.workLoadBar.maximumValue = 10.0
			self.workLoadBar.value = self.totalHoursToWork / Float(self.numOfDays)
			print(numOfDays)
			
			for index in 0...(7-today.weekdayIndex) {
				eventDays.append(today.weekView.dayViews[today.weekdayIndex + index - 1])
			}
			if (numOfWeeks > 0) {
				if (self.numOfWeeks == 1) {
					for index in 0...((self.numOfDays-(7-today.weekdayIndex+1))%7-1) {
						eventDays.append(today.weekView.monthView.weekViews[today.weekView.index+numOfWeeks].dayViews[index])
					}
				}
				else {
					for index in 1...(self.numOfWeeks-1) {
						for day in today.weekView.monthView.weekViews[today.weekView.index+index].dayViews {
							eventDays.append(day)
						}
					}
				}
				if ((self.numOfDays-(7-today.weekdayIndex+1))%7 > 0 && self.numOfWeeks > 1){
					for index in 0...((self.numOfDays-(7-today.weekdayIndex+1))%7-1) {
						eventDays.append(today.weekView.monthView.weekViews[today.weekView.index+numOfWeeks].dayViews[index])
					}
				}
			}
			for index in 0...(eventDays.count-1) {
				print(eventDays[index].date.commonDescription)
			}
		}
	}
	
	
}

// MARK: - Convenience API Demo

//extension ViewController {
//    func toggleMonthViewWithMonthOffset(offset: Int) {
//        let calendar = NSCalendar.currentCalendar()
//        let calendarManager = calendarView.manager
//        let components = Manager.componentsForDate(NSDate()) // from today
//        
//        components.month += offset
//        
//        let resultDate = calendar.dateFromComponents(components)!
//        
//        self.calendarView.toggleViewWithDate(resultDate)
//    }
//    
//    func didShowNextMonthView(date: NSDate)
//    {
//        let calendar = NSCalendar.currentCalendar()
//        let calendarManager = calendarView.manager
//        let components = Manager.componentsForDate(date) // from today
//        
//        print("Showing Month: \(components.month)")
//    }
//    
//    
//    func didShowPreviousMonthView(date: NSDate)
//    {
//        let calendar = NSCalendar.currentCalendar()
//        let calendarManager = calendarView.manager
//        let components = Manager.componentsForDate(date) // from today
//        
//        print("Showing Month: \(components.month)")
//    }
//    
//}