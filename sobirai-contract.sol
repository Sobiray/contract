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
    
        
    function getEvent(bytes32 evId) public returns( EVENT_STATUS status,
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
    
    function startPresale(bytes32 eventId){
        EVENT_STATUS event_status;
        (event_status, )= getEvent(eventId);
        if (event_status ==EVENT_STATUS.CREATED){
            getEvent(eventId).status = EVENT_STATUS.FUNDRASING;
        }
    }
    
    function cancelPresale(bytes32 eventId){
        Event storage e = getEvent(eventId);
        if (e.status==EVENT_STATUS.FUNDRASING){
            e.status = EVENT_STATUS.CANCELED;
        }
    }
    
    function failPresale(bytes32 eventId){
        Event storage e = getEvent(eventId);
        if (e.status==EVENT_STATUS.FUNDRASING){
            e.status = EVENT_STATUS.FAILED;
        }
    }
    
    function successPresale(bytes32 eventId){
        Event storage e = getEvent(eventId);
        if (e.status==EVENT_STATUS.FUNDRASING){
            e.status = EVENT_STATUS.SUCCESS;
        }
    }
    
    function checkEndPresale(bytes32 eventId){
        Event storage e = getEvent(eventId);
        if (e.endPresaleDate<now){
            if (e.currentSum>=e.successSum){
                successPresale(eventId);
            }
            else{
                failPresale(eventId);
            }
        }
    }
    
    function addGuest(
        bytes32 eventId,
        bytes32 guestId,
        uint256 buyDate) 
    public {
        guests[eventId].push(Guest(
            {eventId : eventId, 
            guestId : guestId,
            buyDate: 0    
            }
            )
        );
    }
    
    
    function getGuest (bytes32 eventId, bytes32 guestId) view returns (Guest){
        Guest[] storage event_guests = guests[eventId];
        for (uint j=0; j<event_guests.length; j++) {
            if (event_guests[j].guestId == guestId) {
                return event_guests[j];
            }
        }
    }
    
    function guestPaid(bytes32 eventId, bytes32 guestId, uint sum){
        Event storage e = getEvent(eventId);
        Guest storage g = getGuest(eventId, guestId);
        g.payDate = now;
        checkEndPresale(eventId);
        if (e.status == EVENT_STATUS.FUNDRASING){
            e.currentSum = e.currentSum + sum;
        }
        if (e.status == EVENT_STATUS.SUCCESS){
            e.currentSum = e.currentSum + sum;
        }
    }


}