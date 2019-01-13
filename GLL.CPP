/*
Author: Samuel R. Blackburn
Internet: wfc@pobox.com

"You can get credit for something or get it done, but not both."
Dr. Richard Garwin

The MIT License (MIT)

Copyright (c) 1996-2019 Sam Blackburn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "nmea0183.h"
#pragma hdrstop

#if defined( _DEBUG ) && defined( _INC_CRTDBG )
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#define new DEBUG_NEW
#endif // _DEBUG

GLL::GLL()
{
   Mnemonic = "GLL";
   Empty();
}

GLL::~GLL()
{
   Mnemonic.clear();
   Empty();
}

void GLL::Empty( void ) noexcept
{
   UTCTime.clear();
   Time = 0;
   IsDataValid = NMEA0183_BOOLEAN::NMEA_Unknown;
   Position.Empty();
}

bool GLL::Parse( SENTENCE const& sentence ) noexcept
{
   /*
   ** GLL - Geographic Position - Latitude/Longitude
   ** Latitude, N/S, Longitude, E/W, UTC, Status
   **
   **        1       2 3        4 5         6 7
   **        |       | |        | |         | |
   ** $--GLL,llll.ll,a,yyyyy.yy,a,hhmmss.ss,A*hh<CR><LF>
   **
   ** Field Number: 
   **  1) Latitude
   **  2) N or S (North or South)
   **  3) Longitude
   **  4) E or W (East or West)
   **  5) Universal Time Coordinated (UTC)
   **  6) Status A - Data Valid, V - Data Invalid
   **  7) Checksum
   */

   /*
   ** First we check the checksum...
   */

   if ( sentence.IsChecksumBad( 7 ) == NMEA0183_BOOLEAN::True )
   {
      SetErrorMessage( "Invalid Checksum" );
      return( false );
   } 

   Position.Parse( 1, 2, 3, 4, sentence );
   UTCTime     = sentence.Field( 5 );
   Time        = sentence.Time( 5 );
   IsDataValid = sentence.Boolean( 6 );

   return( true );
}

std::string GLL::PlainEnglish( void ) const noexcept
{
   std::string return_string( "At " );
   std::string time_string = ctime(&Time);
   return_string += time_string.substr(0, time_string.length() - 1);
   return_string += " you were at ";
   return_string += Position.PlainEnglish();
   return_string += ".";

   return( return_string );
}

bool GLL::Write( SENTENCE& sentence ) const noexcept
{
   /*
   ** Let the parent do its thing
   */
   
   RESPONSE::Write( sentence );

   sentence += Position;
   sentence += UTCTime;
   sentence += IsDataValid;

   sentence.Finish();

   return( true );
}

GLL const& GLL::operator = ( GLL const& source ) noexcept
{
   Position    = source.Position;
   UTCTime     = source.UTCTime;
   Time        = source.Time;
   IsDataValid = source.IsDataValid;

   return( *this );
}