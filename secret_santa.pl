#!/usr/bin/perl -w

use strict;
use warnings;

# No cheating
use Math::Random::Secure qw(irand);

use Email::MIME;
use Email::Sender::Simple qw(sendmail);

sub split_name_pair($)
{
   my ($name_pair) = @_;

   $name_pair =~ /^(.+) <(.+@.+\..+)>$/;
   my $name = $1;
   my $email = $2;

   my @split_pair = ($name, $email);

   return \@split_pair;
}

sub shuffle_array
{
   my $array = shift;

   my $i = scalar(@$array);
   while ( --$i )
   {
      my $j = irand( $i+1 );
      @$array[$i,$j] = @$array[$j,$i];
   }
}

my $name_list = 'Aleksejs Sazonovs <as45@sanger.ac.uk>,Daniel Rice <dr9@sanger.ac.uk>,Liu He <lh15@sanger.ac.uk>,Hilary Martin <hcm@sanger.ac.uk>,Jeremy McRae <jm33@sanger.ac.uk>,John Lees <jl11@sanger.ac.uk>,Juliet Handsaker <jh34@sanger.ac.uk>,Katrina de Lange <kdl@sanger.ac.uk>,Mari Niemi <mn2@sanger.ac.uk>,Benjamin Bai <bb9@sanger.ac.uk>,Jeffrey Barrett <jb26@sanger.ac.uk>,Masa Mirkov <mm26@sanger.ac.uk>,Rebecca McIntyre <rm5@sanger.ac.uk>,Tarjinder Singh <ts14@sanger.ac.uk>';

# Parse names
my @name_pairs = split(",", $name_list);

# thanks Hannah Fry https://www.youtube.com/watch?v=5kC5k5QBqcc
# copy this list, each shuffled person then gets the name in front
shuffle_array(\@name_pairs);

# Send emails
my $i = 0;
foreach my $name (@name_pairs)
{
   my $parse_name = split_name_pair($name);
   my $set_name;
   if ($i + 1 == scalar(@name_pairs))
   {
      $set_name = split_name_pair($name_pairs[0]);
   }
   else
   {
      $set_name = split_name_pair($name_pairs[$i+1]);
   }

   my $email_string = <<EMAIL;
Merry Xmas $$parse_name[0]!

As an attendee of the t143 Christmas dinner you have also inadvertently signed up for a Secret Santa: congratulations!

You should anonymously buy a gift, up to the value of five pounds for $$set_name[0]. Make sure it's really relevant and funny, or you won't be invited next year. Also, no telling each other who you're buying for, and no bullying other people into telling you this top-secret information.

You can bring your wrapped gifts to me in E204 and use one of the special labels to avoid any handwriting sleuthing. Make sure you hand them over at the latest on the day of the dinner (14th December).

Have fun shopping!
Your most enthusiastic Christmas participant,
John

p.s. opting out is verboten

(code available at https://github.com/johnlees/derangement)

EMAIL

   my $message = Email::MIME->create(
     header_str => [
       From    => 'jl11@sanger.ac.uk',
       #test
       #To      => 'jl11@sanger.ac.uk',
       To      => "$$parse_name[1]",
       Subject => 'Secret Santa draw (for your eyes only)',
     ],
     attributes => {
       type => 'text/html',
       encoding => 'quoted-printable',
       charset  => 'utf-8',
     },
     body_str => $email_string,
   );
   sendmail($message);

   $i++;
   # See the results. Naughty...
   # ...but a good idea, as it got messed up last year by people dropping
   # out/emails bouncing
   print join("\t", @$parse_name, @$set_name) . "\n";
}

exit(0);

