SELECT 'CustomerPayments' as tbl, count(*) FROM "CustomerPayment"
UNION ALL SELECT 'PaymentAllocations', count(*) FROM "PaymentAllocation"
UNION ALL SELECT 'SupplierPayments', count(*) FROM "SupplierPayment"
UNION ALL SELECT 'SupplierPaymentAllocations', count(*) FROM "SupplierPaymentAllocation"
UNION ALL SELECT 'Bookings', count(*) FROM "Booking"
UNION ALL SELECT 'BookingServices', count(*) FROM "BookingService";
