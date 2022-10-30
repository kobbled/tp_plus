import test_import

status := SR[1]

status = Str::set('Starting Find Zero')
Sense::findZero()
status = Str::set('Find complete')

print_nr(&Sense::measure)
