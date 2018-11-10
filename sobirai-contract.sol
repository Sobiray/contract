pragma solidity ^0.4.0;

contract Sobirai {
    
    enum EVENT_STATUS { CREATED, FUNDRASING, CANCELED, FAILED, SUCCESS }
    
    struct Guest{
        bytes32 guestId;
        bytes32 eventId;
        uint256 payDate;
    }
    
    struct Event {
        EVENT_STATUS status;
        bytes32 eventId;
        uint successSum;
        uint currentSum;
        uint maxGuestsCount;
        uint presaleCost;
        uint saleCost;
        uint256 endPresaleDate;
    }
    Event[] events;
    mapping(bytes32 => Guest[]) private guests;

    constructor() public {}

    function addEvent(
        bytes32 eventId,
        uint successSum,
        uint maxGuestsCount,
        uint presaleCost,
        uint saleCost,
        uint256 endPresaleDate) 
    public {
        events.push(Event({status:EVENT_STATUS.CREATED, 
        eventId:eventId, 
        successSum:successSum,
        currentSum:0,
        maxGuestsCount:maxGuestsCount, 
        presaleCost: presaleCost, 
        saleCost: saleCost,
        endPresaleDate: endPresaleDate}));
    }
    
        
    function getEvent(bytes32 evId) public view returns( EVENT_STATUS status,
                                                            bytes32 eventId,
                                                            uint successSum,
                                                            uint currentSum,
                                                            uint maxGuestsCount,
                                                            uint presaleCost,
                                                            uint saleCost,
                                                            uint256 endPresaleDate)
                    {
        for (uint i=0; i<events.length; i++) {
          if (events[i].eventId == evId) {
            Event storage e = events[i];
            return( e.status,
                    e.eventId,
                    e.successSum,
                    e.currentSum,
                    e.maxGuestsCount,
                    e.presaleCost,
                    e.saleCost,
                    e.endPresaleDate);
          }
        }
    }
    
    function getEventStatus(bytes32 eventId) public view returns (EVENT_STATUS status){
        uint successSum;
        uint currentSum;
        uint maxGuestsCount;
        uint presaleCost;
        uint saleCost;
        uint256 endPresaleDate;
  
        (status, eventId, successSum, currentSum, maxGuestsCount, presaleCost, saleCost, endPresaleDate)= getEvent(eventId);
    }
    
    function setEventStatus(bytes32 evId, EVENT_STATUS status) public 
    {
        for (uint i=0; i<events.length; i++) {
          if (events[i].eventId == evId) {
            Event storage e = events[i];
            e.status = status;
            break;
        }
     }
    }
    
    function changeEventCurrentSum(bytes32 evId, uint delta) private 
    {
        for (uint i=0; i<events.length; i++) {
          if (events[i].eventId == evId) {
            Event storage e = events[i];
            e.currentSum = e.currentSum + delta;
            break;
        }
     }
    }
    
    function startPresale(bytes32 eventId) public{
    EVENT_STATUS status = getEventStatus(eventId);
    if (status == EVENT_STATUS.CREATED){
            setEventStatus(eventId, EVENT_STATUS.FUNDRASING);
        }
    }
    
    function cancelPresale(bytes32 eventId) public{
    EVENT_STATUS status = getEventStatus(eventId);
    if (status == EVENT_STATUS.FUNDRASING){
            setEventStatus(eventId, EVENT_STATUS.CANCELED);
        }
    }
    
    function failPresale(bytes32 eventId) public{
    EVENT_STATUS status = getEventStatus(eventId);
    if (status == EVENT_STATUS.FUNDRASING){
            setEventStatus(eventId, EVENT_STATUS.FAILED);
        }
    }
    
    function successPresale(bytes32 eventId) public{
    EVENT_STATUS status = getEventStatus(eventId);
    if (status == EVENT_STATUS.FUNDRASING){
            setEventStatus(eventId, EVENT_STATUS.SUCCESS);
        }
    }
    
    function checkEndPresale(bytes32 eventId) public{
        EVENT_STATUS status;
        uint successSum;
        uint currentSum;
        uint maxGuestsCount;
        uint presaleCost;
        uint saleCost;
        uint256 endPresaleDate;
  
        (status, eventId, successSum, currentSum, maxGuestsCount, presaleCost, saleCost, endPresaleDate)= getEvent(eventId);
        if (endPresaleDate<now){
            if (currentSum>=successSum){
                successPresale(eventId);
            }
            else{
                failPresale(eventId);
            }
        }
    }
    
    function addGuest(
        bytes32 eventId,
        bytes32 guestId) 
    public {
        guests[eventId].push(Guest(
            {eventId : eventId, 
            guestId : guestId,
            payDate: 0    
            }
            )
        );
    }
    
    function setGuestPayDate(bytes32 eventId, bytes32 guestId, uint256 date) private{
        Guest[] storage event_guests = guests[eventId];
        for (uint j=0; j<event_guests.length; j++) {
            if (event_guests[j].guestId == guestId) {
                Guest storage g = event_guests[j];
                g.payDate = date;
            }
        }
    }
    
    function guestPaid(bytes32 eventId, bytes32 guestId, uint sum) public{
        EVENT_STATUS status = getEventStatus(eventId);
        setGuestPayDate(eventId, guestId, now);
        checkEndPresale(eventId);
        if (status == EVENT_STATUS.FUNDRASING){
            changeEventCurrentSum(eventId, sum);
        }
        if (status == EVENT_STATUS.SUCCESS){
            changeEventCurrentSum(eventId, sum);
        }
    }

}