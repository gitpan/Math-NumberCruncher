package Math::NumberCruncher;

require Exporter;

@ISA = qw(Exporter AutoLoader);

$VERSION = '2.0';

use strict;
use constant epsilon => 1E-10;
use Math::BigFloat;

my $PI = new Math::BigFloat "3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196";

sub Range {
	my $arrayref = shift;
	my ( $zzz, $hi, $lo );
	$hi = $lo = $$arrayref[0];
	foreach $zzz ( @$arrayref ) {
		if ( $zzz > $hi ) {
			$hi = $zzz;
		}
		if ( $zzz < $lo ) {
			$lo = $zzz;
		}
	}
	if ( $lo eq "" ) { $lo = "0" }
	return ( $hi, $lo );
}

sub Mean {
	my $arrayref = shift;
	my $result;
	foreach (@$arrayref) { $result += $_ }
	return $result / @$arrayref;
}

sub Median { # median may or may not be an element of the array
	my $arrayref = shift;
	my $median = undef;
	my @array = sort { $a <=> $b } @$arrayref;
	if ( @array % 2 ) {
		$median = $array[@array/2];
	} else {
		$median = ($array[@array/2-1] + $array[@array/2]) /2;
	}
	return $median;
}

sub OddMedian { # median *is* an element of the array
	my $arrayref = shift;
	my @array = sort { $a <=> $b } @$arrayref;
	return $array[(@array - (0,0,1,0)[@array & 3]) / 2];
}

sub Mode {
	my $arrayref = shift;
	my ( %count, @result );
	foreach ( @$arrayref) { $count{$_}++ }
	foreach ( sort { $count{$b} <=> $count{$a} } keys %count) {
		last if @result && $count{$_} != $count{$result[0]};
		push ( @result, $_ );
	}
	return OddMedian \@result;
}

sub Covariance {
	my ( $array1ref, $array2ref ) = @_;
	my ( $i, $result );
	for ( $i = 0; $i < @$array1ref; $i++ ) {
		$result += $array1ref->[$i] * $array2ref->[$i];
	}
	$result /= @$array1ref;
	$result -= Mean( $array1ref) * Mean( $array2ref);
	return $result;
}

sub Correlation {
	my ( $array1ref, $array2ref ) = @_;
	my ( $sum1, $sum2, $sum1_sqrd, $sum2_sqrd);
	foreach ( @$array1ref ) {
		$sum1 += $_;
		$sum1_sqrd += $_**2;
	}
	foreach ( @$array2ref ) {
		$sum2 += $_;
		$sum2_sqrd += $_**2;
	}
	return ( @$array1ref ** 2 ) * Covariance( $array1ref,$array2ref ) / 
		sqrt((( @$array1ref * $sum1_sqrd ) - ( $sum1 ** 2 )) * 
		(( @$array1ref * $sum2_sqrd ) - ( $sum2 ** 2 )));
}

sub BestFit {
	my( $a_ref, $b_ref ) = @_;
	my ( $i, $product, $sum1, $sum2, $sum1_sqrs, $a, $b );
	for ( $i = 0; $i <= @$a_ref; $i++ ) {
		$product += $a_ref->[$i] * $b_ref->[$i];
		$sum1 += $a_ref->[$i];
		$sum1_sqrs += $a_ref->[$i]**2;
		$sum2 += $b_ref->[$i];
	}
	$b = (( @$a_ref * $product ) - ( $sum1 * $sum2 )) /
		(( @$a_ref * $sum1_sqrs ) - ( $sum1 ** 2 ));
	$a = ( $sum2 - $b * $sum1 ) / @$a_ref;
	return( $b, $a );
}

sub Distance { # Distance( $x1, $y1, $x2, $y2 );
	my @p = @_;
	my $d = @p / 2;
	return sqrt(( $_[0] - $_[2] ) ** 2 + ( $_[1] - $_[3] ) ** 2 ) if $d == 2;
	my $S = 0;
	my @p0 = splice @p, 0, $d;
	for ( my $i = 0; $i < $d; $i++ ) {
		my $di = $p0[$i] - $p[$i];
		$S += $di * $di;
	}
	return sqrt( $S );
}

sub ManhattanDistance {
	my @p = @_;
	my $d = @p / 2;
	my $S = 0;
	my @p0 = splice @p, 0, $d;
	for ( my $i = 0; $i < $d; $i++ ) {
		my $di = $p0[$i] - $p[$i];
		$S += abs $di;
	}
	return $S;
}

sub AllOf { 
	my $result = 1;
	while ( @_ ) {
		$result *= shift;
	}
	return $result;
}

sub NoneOf {
	my $result = 1;
	while ( @_ ) {
		$result *= ( 1 - shift );
	}
	return $result;
}

sub SomeOf {
	return 1 - &NoneOf;
}

sub Factorial {
	my $n = shift;
	my $result = 1;
	unless ( $n >= 0 && $n == int( $n ) ) {
		return undef;
	}
	while ( $n > 1 ) {
		$result *= $n--;
	}
	return $result;
}

sub Permutation {
	my ( $n, $k ) = @_;
	my $result = 1;

	defined $k or $k = $n;
	while ( $k-- ) { $result *= $n-- }
	return $result;
}

sub Dice {
	my $number = shift || 1;
	my $sides = shift || 6;
	my $plus = shift;
	while ( $number-- ) {
		$plus += int( rand($sides) );
	}
	return $plus;
}

sub RandInt {
	my $low = shift || 0;
	my $high = shift || 1;

	if ( $low > $high ) {
		( $low, $high ) = ( $high, $low );
	}
	return $low + int( rand( $high - $low + 1 ) );
}

sub RandomElement {
	$_[0]->[ rand @{ $_[0] } ];
}

sub ShuffleArray {
	my $array = shift;
	for ( my $i = @$array; --$i; ) {
		my $j = int rand ($i+1);
		next if $i == $j;
		@$array[$i,$j] = @$array[$j,$i];
	}
}

sub Unique {
	my $arrayref = shift;
	my %seen = ();
	my $zzz;
	my @unique;
	foreach $zzz ( @$arrayref ) {
		push ( @unique, $zzz ) unless $seen{$zzz}++;
	}
	return @unique;
}

sub Compare {
	my ( $arrayref1, $arrayref2 ) = @_;
	my %seen;
	my @aonly;
	my $item;
	@seen{@$arrayref2} = ();
	foreach $item ( @$arrayref1 ) {
		push(@aonly, $item) unless $seen{$item};
		$seen{$item} = 1;                       # mark as seen
	}
	return @aonly;
}

sub Union {
	my ( $arrayref1, $arrayref2 ) = @_;
	my @union = undef;
	my @temp = undef;
	my %union = ();
	my $zzz;
	push ( @temp, @$arrayref1 );
	push ( @temp, @$arrayref2 );
	foreach $zzz ( @temp ) {
		$union{$zzz} = 1;
	}
	@union = keys %union;
	return @union;
}

sub Intersection {
	my ( $arrayref1, $arrayref2 ) = @_;
	my @isect = undef;
	my %isect = ();
	my %union = ();
	my %count = ();
	my $zzz;
	foreach $zzz ( @$arrayref1 ) {
		$union{$zzz} = 1;
	}
	foreach $zzz ( @$arrayref2 ) {
		if ( $union{$zzz} ) {
			$isect{$zzz} = 1;
		}
	}
	@isect = keys %isect;
	return @isect;
}

sub Difference {
     my ( $arrayref1, $arrayref2 ) = @_;
     my ( @isect, @diff, @union ) = undef;
     my $zzz;
     my %count = ();
     foreach $zzz (@$arrayref1, @$arrayref2) { $count{$zzz}++ }
     foreach $zzz (keys %count) {
          push @union, $zzz;
          push @{ $count{$zzz} > 1 ? \@isect : \@diff }, $zzz;
     }
     return @diff;
}

sub GaussianRand {
	my ($u1, $u2);
	my $w;
	my ($g1, $g2);

	while ( $w >= 1 ) {
		$u1 = 2 * rand() - 1;
		$u2 = 2 * rand() - 1;
		$w = $u1 * $u1 + $u2 * $u2;
	}

	$w = sqrt( (-2 * log($w))  / $w );
	$g2 = $u1 * $w;
	$g1 = $u2 * $w;
	return wantarray ? ($g1, $g2) : $g1;
}

sub Choose { # Probability of getting $k heads is $n tosses
	my ( $n, $k ) = @_;
	my ( $result, $j ) = ( 1, 1 );
	if ( $k > $n || $k < 0 ) {
		return 0;
	}
	while ( $j <= $k ) {
		$result *= $n--;
		$result /= $j++;
	}
	return $result;
}

sub Binomial { # probability of $k successes in $n attempts, given probability of $p
	my ( $n, $k, $p ) = @_;
	return $k == 0 if $p == 0;
	return $k != $n if $p == 1;
	return Choose( $n, $k ) * $p ** $k * ( 1 - $p ) ** ( $n - $k );
}

sub GaussianDist {
	use constant two_pi_sqrt_inverse => 1 / sqrt( 8 * atan2( 1, 1 ) );
	my ( $x, $mean, $variance ) = @_;
	return two_pi_sqrt_inverse * exp( -( $x - $mean ) ** 2 /
		( 2 * $variance ) ) / sqrt $variance;
}

sub StandardDeviation {
	my $arrayref = shift;
	my $mean = Mean( $arrayref );
	return sqrt( Mean( [map $_ ** 2, @$arrayref] ) - ( $mean ** 2 ) );
}

sub Variance {
	my $arrayref = shift;
	return StandardDeviation( $arrayref ) ** 2;
}

sub StandardScores { # number of StdDevs above the mean for each element
	my $arrayref = shift;
	my $mean = Mean( $arrayref );
	my ( $i, @scores );
	my $deviation = StandardDeviation( $arrayref );
	return unless $deviation;
	for ( $i = 0; $i < @$arrayref; $i++ ) {
		push @scores, ( $arrayref->[$i] - $mean ) / $deviation;
	}
	return @scores;
}

sub SignSignificance {
	my ( $trials, $hits, $probability ) = @_;
	my $confidence;
	foreach ( $hits..$trials ) {
		$confidence += Binomial( $trials, $hits, $probability );
	}
	return $confidence;
}


sub EMC2 {
	my $var = shift;
	my $unit = shift;
	my $C;
	if ( $unit eq "" ) {
		$C = 299792.458; # km per second
	} else {
		$C = 186282.056; # miles per second
	}
	my $result;
	$var = lc $var;
	if ( $var =~ /^m(.*)$/ ) {
		my $val = $1;
		$result = $val * $C ** 2;
	} elsif ( $var =~ /^e(.*)$/ ) {
		my $val = new Math::BigFloat $1;
		$result = $val->fdiv( $C ** 2 );
	} else {
		return undef;
	}
	return $result;
}

sub FMA {
	my @vars = @_;
	@vars = sort @vars;
	my ( $result, $acc, $force, $mass ) = undef;
	if ( $vars[0] =~ /^[Aa](.*)$/ ) {
		$acc = $1;
	} elsif ( $vars[0] =~ /^[Ff](.*)$/ ) {
		$force = $1;
	}
	if ( $vars[1] =~ /^[Ff](.*)$/ ) {
		$force = $1;
	} elsif ( $vars[1] =~ /^[Mm](.*)$/ ) {
		$mass = $1;
	}
	if ( $acc && $force ) {
		$result = $force / $acc;
	} elsif ( $acc && $mass ) {
		$result = $acc * $mass;
	} elsif ( $force && $mass ) {
		$result = $force / $mass;
	} else {
		return undef;
	}
	return $result;
}

sub Predict {
	my ( $slope, $y_intercept, $proposed ) = @_;
	return $slope * $proposed + $y_intercept;
}

sub TriangleHeron {
	my ( $a, $b, $c );
	
	if ( @_ == 3 ) { 
		( $a, $b, $c ) = @_;
	} elsif ( @_ == 6 ) {
		( $a, $b, $c ) = (
			Distance( $_[0], $_[1], $_[2], $_[3] ),
			Distance( $_[2], $_[3], $_[4], $_[5] ),
			Distance( $_[4], $_[5], $_[0], $_[1] ) );
	}
	my $s = ( $a + $b + $c ) / 2;
	return sqrt( $s * ( $s - $a ) * ( $s - $b ) * ( $s - $c ) );
}												

sub PolygonPerimeter {
	my @xy = @_;
	my $P = 0;
	
	for ( my ( $xa, $ya ) = @xy[ -2, -1 ]; my ( $xb, $yb ) = splice @xy, 0, 2; ( $xa, $ya ) = ( $xb, $yb ) ) {
		$P += Distance( $xa, $ya, $xb, $yb );
	}
	
	return $P;
}

sub Clockwise {
	my ( $x0, $y0, $x1, $y1, $x2, $y2 ) = @_;
	return ( $x2 - $x0 ) * ( $y1 - $y0 ) - ( $x1 - $x0 ) * ( $y2 - $y0 );
}

sub InPolygon {
	my ( $x, $y, @xy ) = @_;
	
	my $n = @xy / 2;
	my @i = map { 2 * $_ } 0 .. (@xy/2);
	my @x = map { $xy[ $_ ] } @i;
	my @y = map { $xy[ $_ + 1 ] } @i;
	
	my ( $i, $j );
	my $side = 0;
	
	for ( $i = 0, $j = $n - 1; $i < $n; $j = $i++ ) {
		if (
			(
				( ( $y[ $i ] <= $y ) && ( $y < $y[ $j ] ) ) ||
				( ( $y[ $j ] <= $y ) && ( $y < $y[ $i ] ) )
			)
			and
			(
				$x < ( $x[ $j ] - $x[ $i ] ) * ( $y - $y[ $i ] ) / ( $y[ $j ] - $y[ $i ] ) + $x[ $i ] 
			) )
		{
			$side = not $side;
		}
	}
	return $side ? 1 : 0;
}

sub BoundingBox_Points { 
	my ( $d, @points ) = @_;
	my @bb;
	while ( my @p = splice @points, 0, $d ) {
		@bb = BoundingBox( $d, @p, @bb );
	}
	return @bb;
}

sub BoundingBox {
	my ( $d, @bb ) = @_;
	my @p = splice( @bb, 0, @bb - 2 * $d );
	
	@bb = ( @p, @p ) unless @bb;
	
	for ( my $i = 0; $i < $d; $i++ ) {
		for ( my $j = 0; $j < @p; $j += $d ) {
			my $ij = $i + $j;
			$bb[$i] = $p[$ij] if $p[$ij] < $bb[$i];
			$bb[$i+$d] = $p[$ij] if $p[$ij] > $bb[$i+$d];
		}
	}
	return @bb;
}

sub InTriangle {
	my ( $x, $y, $x0, $y0, $x1, $y1, $x2, $y2 ) = @_;
	my $cw0 = Clockwise( $x0, $y0, $x1, $y1, $x, $y );
	return 1 if abs( $cw0 ) < epsilon;
	my $cw1 = Clockwise( $x1, $y1, $x2, $y2, $x, $y );
	return 1 if abs( $cw1 ) < epsilon;
	return 0 if ( $cw0 < 0 and $cw1 > 0 ) or ( $cw0 > 0 and $cw1 < 0 );
	
	my $cw2 = Clockwise( $x2, $y2, $x0, $y0, $x, $y );
	return 1 if abs( $cw2 ) < epsilon;
	return 0 if ( $cw0 < 0 and $cw2 > 0 ) or ( $cw0 > 0 and $cw2 < 0 );
	
	return 1;
}

sub PolygonArea {
	my @xy = @_;
	my $A = 0;
	for ( my ( $xa, $ya ) = @xy[-2, -1];
		my ( $xb, $yb ) = splice @xy, 0, 2;
		( $xa, $ya ) = ( $xb, $yb ) ) {
		$A += Determinant( $xa, $ya, $xb, $yb );
	}
	return abs $A / 2;
}

sub Determinant {
	$_[0] * $_[3] - $_[1] * $_[2];
}	

sub CircleArea {
	my $radius = shift;
	my $area = $PI * ($radius ** 2);
	return $area;
}

sub Circumference {
	my $diameter = shift;
	return $PI * $diameter;
}

sub SphereVolume { 
	my $radius = shift;
	my $volume = (4/3) * $PI * ($radius ** 3);
	return $volume;
}

sub SphereSurface {
	my $radius = shift;
	my $surface = 4 * $PI * ($radius ** 2);
	return $surface;
}

1;
__END__

=head1 NAME

Math::NumberCruncher - Very useful, commonly needed math/statistics/geometric functions.

=head1 SYNOPSIS

use Math::NumberCruncher;

($high, $low) = Math::NumberCruncher::Range(\@array);

$mean = Math::NumberCruncher::Mean(\@array);

$median = Math::NumberCruncher::Median(\@array);

$odd_median = Math::NumberCruncher::OddMedian(\@array);

$mode = Math::NumberCruncher::Mode(\@array);

$covariance = Math::NumberCruncher::Covariance(\@array1, \@array2);

$correlation = Math::NumberCruncher::Correlation(\@array1, \@array2);

($slope, $y_intercept) = Math::NumberCruncher::BestFit(\@array1, \@array2);

$distance = Math::NumberCruncher::Distance($x1,$y1,$z1,$x2,$y2,$z2);

$distance = Math::NumberCruncher::Distance($x1,$y1,$x1,$x2);

$distance = Math::NumberCruncher::ManhattanDistance($x1,$y1,$x2,$y2);

$probAll = Math::NumberCruncher::AllOf('0.3','0.25','0.91','0.002');

$probNone = Math::NumberCruncher::NoneOf('0.4','0.5772','0.212');

$probSome = Math::NumberCruncher::SomeOf('0.11','0.56','0.3275');

$factorial = Math::NumberCruncher::Factorial($some_number);

$permutations = Math::NumberCruncher::Permutation($n);

$permutations = Math::NumberCruncher::Permutation($n,$k);

$roll = Math::NumberCruncher::Dice(3,12,4);

$randInt = Math::NumberCruncher::RandInt(10,50);

$randomElement = Math::NumberCruncher::RandomElement(\@array);

@shuffled = Math::NumberCruncher::ShuffleArray(\@array);

@unique = Math::NumberCruncher::Unique(\@array);

@a_only = Math::NumberCruncher::Compare(\@a,\@b);

@union = Math::NumberCruncher::Union(\@a,\@b);

@intersection = Math::NumberCruncher::Intersection(\@a,\@b);

@difference = Math::NumberCruncher::Difference(\@a,\@b);

$gaussianRand = Math::NumberCruncher::GaussianRand();

$prob = Math::NumberCruncher::Choose($n,$k);

$binomial = Math::NumberCruncher::Binomial($attempts,$successes,$probability);

$gaussianDist = Math::NumberCruncher::GaussianDist($x,$mean,$variance);

$StdDev = Math::NumberCruncher::StandardDeviation(\@array);

$variance = Math::NumberCruncher::Variance(\@array);

@scores = Math::NumberCruncher::StandardScores(\@array);

$confidence = Math::NumberCruncher::SignSignificance($trials,$hits,$probability);

$e = Math::Numbercruncher::EMC2( "m512" [, 1] );

$m = Math::NumberCruncher::EMC2( "e987432" [, 1] );

$force = Math::NumberCruncher::FMA( "m12", "a73.5" );

$mass = Math::NumberCruncher::FMA( "a43", "f1324" );

$acceleration = Math::NumberCruncher::FMA( "f53512", "m356" );

$predicted_value = Math::NubmerCruncher::Predict( $slope, $y_intercept, $proposed_x );

$area = Math::NumberCruncher::TriangleHeron( $a, $b, $c );

$area = Math::NumberCruncher::TriangleHeron( 1,3, 5,7, 8,2 );

$perimeter = Math::NumberCruncher::PolygonPerimeter( $x0,$y0, $x1,$y1, $x2,$y2, ...);

$direction = Math::NumberCruncher::Clockwise( $x0,$y0, $x1,$y1, $x2,$y2 );

$collision = Math::NumberCruncher::InPolygon( $x, $y, @xy );

@points = Math::NumberCruncher::BoundingBox_Points( $d, @p );

$in_triangle = Math::NumberCruncher::InTriangle( $x,$y, $x0,$y0, $x1,$y1, $x2,$y2 );

$area = Math::NumberCruncher::PolygonArea( 0, 1, 1, 0, 2, 0, 3, 2, 2, 3 );

$area = Math::NumberCruncher::CircleArea( $diameter );

$circumference = Math::NumberCruncher::Circumference( $diameter );

$volume = Math::NumberCruncher::SphereVolume( $radius );

$surface_area = Math::NumberCruncher::SphereSurface( $radius );

=head1 DESCRIPTION

This module is a collection of commonly needed number-related functions, including numerous
standard statistical, geometric, and probability functions.  Some of these functions are taken
directly from _Mastering Algorithms with Perl_, by Jon Orwant, Jarkko Hietaniemi, and John
Macdonald, and others are adapted heavily from same.  The remainder are either original
functions written by the author, or original adaptations of standard algorithms.  Some of the
functions are fairly obvious, others are explained in greater detail below.  For all 
calculations involving pi, the value of pi is taken out to 100 places. Overkill? Probably, 
but it is better, in my opinion, to have too much accuracy as opposed to not enough.

=head1 EXAMPLES

=item ($high,$low) = B<Math::NumberCruncher::Range>(\@array);

Returns the largest and smallest elements in an array.

=item $mean = B<Math::NumberCruncher::Mean>(\@array);

Returns the mean, or average, of an array.

=item $median = B<Math::NumberCruncher::Median>(\@array);

Returns the median, or the middle, of an array.  The median may or may not be an element of
the array itself.

=item $odd_median = B<Math::NumberCruncher::OddMedian>(\@array);

Returns the odd median, which, unlike the median, *is* an element of the array.  In all other
respects it is similar to the median.

=item $mode = B<Math::NumberCruncher::Mode>(\@array);

Returns the mode, or most frequently occurring item, of @array.

=item $covariance = B<Math::NumberCruncher::Covariance>(\@array1,\@array2);

Returns the covariance, which is a measurement of the correlation of two variables.

=item $correlation = B<Math::NumberCruncher::Correlation>(\@array1,\@array2);

Returns the correlation of two variables. Correlation ranges from 1 to -1, with a correlation
of zero meaning no correlation exists between the two variables.

=item ($slope,$y_intercept ) = B<Math::NumberCruncher::BestFit>(\@array1,\@array2);

Returns the slope and y-intercept of the line of best fit for the data in question.

=item $distance = B<Math::NumberCruncher::Distance>($x1,$y1,$x1,$x2);

Returns the Euclidian distance between two points.  The above example demonstrates the use in
two dimensions. For three dimensions, use would be B<$distance = B<Math::NumberCruncher::Distance>($x1,$y1,$z1,$x2,$y2,$z2);>

=item $distance = B<Math::NumberCruncher::ManhattanDistance>($x1,$y1,$x2,$y2);

Modified two-dimensional distance between two points. As stated in _Mastering Algorithms with
Perl_, "Helicopter pilots tend to think in Euclidian distance, good New York cabbies tend to
think in Manhattan distance." Rather than distance "as the crow flies," this is distance based
on a rigid grid, or network of streets, like those found in Manhattan.

=item $probAll = B<Math::NumberCruncher::AllOf>('0.3','0.25','0.91','0.002');

The probability that B<all> of the probabilities in question will be satisfied. (i.e., the
probability that the Steelers will win the SuperBowl B<and> that David Tua will win the World
Heavyweight Title in boxing.)

=item $probNone = B<Math::NumberCruncher::NoneOf>('0.4','0.5772','0.212');

The probability that B<none> of the probabilities in question will be satisfied. (i.e., the
probability that the Steelers will not win the SuperBowl and that David Tua will not win the
World Heavyweight Title in boxing.)

=item $probSome = B<Math::NumberCruncher::SomeOf>('0.11','0.56','0.3275');

The probability that at least one of the probabilities in question will be satisfied. (i.e.,
the probability that either the Steelers will win the SuperBowl B<or> David Tua will win the
World Heavyweight Title in boxing.)

=item $factorial = B<Math::NumberCruncher::Factorial>($some_number);

The number of possible orderings of $factorial items. The factorial n! gives the number of
ways in which n objects can be permuted.

=item $permutations = B<Math::NumberCruncher::Permutation>($n);

The number of permutations of $n elements.

=item $permutations = B<Math::NumberCruncher::Permutation>($n,$k);

The number of permutations of $k elements drawn from a set of $n elements.

=item $roll = B<Math::NumberCruncher::Dice>($number,$sides,$plus);

The obligatory dice rolling routine. Returns the result after passing the number of rolls of
the die, the number of sides of the die, and any additional points to be added to the roll.  
As commonly seen in role playing games, 4d12+5 would be expressed as B<Dice(4,12,5)>.  The
function defaults to a single 6-sided die rolled once without any points added.

=item $randInt = B<Math::NumberCruncher::RandInt>(10,50);

Returns a random integer between the two number passed to the function, inclusive. With no
parameters passed, the function returns either 0 or 1.

=item $randomElement = B<Math::NumberCruncher::RandomElement>(\@array);

Returns a randome element from @array.

=item @shuffled = B<Math::NumberCruncher::ShuffleArray>(\@array);

Shuffles the elements of @array and returns them.

=item @unique = B<Math::NumberCruncher::Unique>(\@array);

Returns an array of the unique items in an array.

=item @a_only = B<Math::NumberCruncher::Compare>(\@a,\@b);

Returns an array of elements that appear only in the first array passed. Any elements that
appear in both arrays, or appear only in the second array, are discarded.

=item @union = B<Math::NumberCruncher::Union>(\@a,\@b);

Returns an array of the unique elements produced from the joining of the two arrays.

=item @intersection = B<Math::NumberCruncher::Intersection>(\@a,\@b);

Returns an array of the elements that appear in both arrays.

=item @difference = B<Math::NumberCruncher::Difference>(\@a,\@b);

Returns an array of the symmetric difference of the two arrays. For example, in the words of
_Mastering Algorithms in Perl_, "show me the web documents that talk about Perl B<or> about
sets B<but not> those that talk about B<both>.

=item $gaussianRand = B<Math::NumberCruncher::GaussianRand>();

Returns one or two floating point numbers based on the Gaussian Distribution, based upon the
call wants an array or a scalar value.

=item $probability = B<Math::NumberCruncher::Choose>($n,$k);

Returns the probability of $k successes in $n tries.

=item $binomial = B<Math::NumberCruncher::Binomial>($n,$k,$p);

Returns the probability of $k successes in $n tries, given a probability of $p. (i.e., if the
probability of being struck by lightning is 1 in 75,000, in 100 days, the probability of being
struck by lightning exactly twice would be expressed as B<Binomial('100','2','0.0000133')>)

=item $probability = B<Math::NumberCruncher::GaussianDist>($x,$mean,$variance);

Returns the probability, based on Gaussian Distribution, of our random variable, $x, given the
$mean and $variance.

=item $StdDev = B<Math::NumberCruncher::StandardDeviation>(\@array);

Returns the Standard Deviation of @array, which is a measurement of how diverse your data is.

=item $variance = B<Math::NumberCruncher::Variance>(\@array);

Returns the variance for @array, which is the square of the standard deviation.  Or think of
standard deviation as the square root of the variance.  Variance is another indicator of the
diversity of your data.

=item @scores = B<Math::NumberCruncher::StandardScores>(\@array);

Returns an array of the number of standard deviations above the mean for @array.

=item $confidence = B<Math::NumberCruncher::SignSignificance>($trials,$hits,$probability);

Returns the probability of how likely it is that your data is due to chance.  The lower the
confidence, the less likely your data is due to chance.

=item $e = B<Math::NumberCruncher::EMC2>( "m36" [, 1] );

Implementation of Einstein's E=MC**2.  Given either energy or mass, the function returns the
other. When passing mass, the value must be preceeded by a "m," which may be either upper or
lower case.  When passing energy, the value must be preceeded by a "e," which may be either
upper or lower case. The function defaults to using kilometers per second for the speed of
light.  To make the function use miles per second for the speed of light, simply pass any
non-zero value as the second value.

=item $force = B<Math::NumberCruncher::FMA>( "m97", "a53" );

Implementation of the stadard force = mass * acceleration formula.  Given two of the three
variables (i.e., mass and force, mass and acceleration, or acceleration and force), the
function returns the third.  When passing the values, mass must be preceeded by a "m," force
must be preceeded by a "f," and acceleration must be preceeded by an "a."  Case is irrelevant.

=item $predicted = B<Math::NumberCruncher::Predict>( $slope, $y_intercept, $proposed_x );

Useful for predicting values based on data trends, as calculated by BestFit(). Given the slope
and y-intercept, and a proposed value of x, returns corresponding y.

=item $area = B<Math::NumberCruncher::TriangleHeron>( $a, $b, $c );

Calculates the area of a triangle, using Heron's formula.  TriangleHeron() can be passed 
either the lengths of the three sides of the triangle, or the (x,y) coordinates of the 
three verticies.

=item $perimeter = B<Math::NumberCruncher::PolygonPerimeter>( $x0,$y0, $x1,$y1, $x2,$y2, ...);

Calculates the length of the perimeter of a given polygon.

=item $direction = B<Math::NumberCruncher::Clockwise>( $x0,$y0, $x1,$y1, $x2,$y2 );

Given three pairs of points, returns a positive number if you must turn clockwise when 
moving from p1 to p2 to p3, returns a negative number if you must turn counter-clockwise
when moving from p1 to p2 to p3, and a zero if the three points lie on the same line.

=item $collision = B<Math::NumberCruncher::InPolygon>( $x, $y, @xy );

Given a set of xy pairs (@xy) that define the perimeter of a polygon, returns a 1 if 
point ($x,$y) is inside the polygon and returns 0 if the point ($x,$y) is outside the polygon.

=item @points = B<Math::NumberCruncher::BoundingBox_Points>( $d, @p );

Given a set of @p points and $d dimensions, returns two points that define the upper left and
lower right corners of the bounding box for set of points @p.

=item $in_triangle = B<Math::NumberCruncher::InTriangle>( $x,$y, $x0,$y0, $x1,$y1, $x2,$y2 );

Returns true if point $x,$y is inside the triangle defined by points ($x0,$y0), ($x1,$y1), 
and ($x2,$y2)

=item $area = B<Math::NumberCruncher::PolygonArea>( 0, 1, 1, 0, 3, 2, 2, 3, 0, 2 );

Calculates the area of a polygon using determinants.

=item $area = B<Math::NumberCruncher::CircleArea>( $diameter );

Calculates the area of a circle, given the diameter.

=item $circumference = B<Math::NumberCruncher::Circumference>( $diameter );

Calculates the circumference of a circle, given the diameter.

=item $volume = B<Math::NumberCruncher::SphereVolume>( $radius );

Calculates the volume of a sphere, given the radius.

=item $surface_area = B<Math::NumberCruncher::SphereSurface>( $radius );

Calculates the surface area of a sphere, given the radius.

=head1 AUTHOR

Kurt Kincaid, sifukurt@yahoo.com
Jon Orwant
Jarkko Hietaniemi
John Macdonald

=head1 SEE ALSO

perl(1).

=cut
