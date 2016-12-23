#perlがインストールされている場所を記入 => .plファイルが実行可能
#!/usr/local/bin/perl -w
# 上の書き方の他に以下の2文を書いても実行可能になる
# use strict;
# use warnings;

# 辞書登録
$doc0 = ("w1 w3 w1 w4");
$doc1 = ("w1 w2 w2 w5 w8");
$doc2 = ("w3 w7 w7 w8 w9");
$doc3 = ("w1 w3 w4 w6");
$doc4 = ("w2 w3 w4 w7 w8");
$delta = 1;                             # 計算がおかしくならないように

&main();

sub main {
    # 辞書1.2.3 => Category0
    push(@category0, split(" ",$doc0), split(" ",$doc1), split(" ",$doc2));
    print 'クラス0中に出現する単語数=',$#category0+1,"個\n";
    # 辞書4.5 => Category1
    push (@category1, split(" ",$doc3), split(" ",$doc4));
    print 'クラス1中に出現する単語数=',$#category1+1,"個\n";

    # サブルーチンに複数の配列を渡すにはリファレンスを使用
    my $refCategory0 = \@category0;	# ポインタを生成
    my $refCategory1 = \@category1;	# ポインタを生成
    my @data = ($refCategory0,$refCategory1);
    &analysis($refCategory0,$refCategory1);
}

sub analysis {  my($r0,$r1) = @_;		# リファレンスをスカラ型で受け取る
    my %hash0 = ();
    my %hash1 = ();
    my %All_word = ();
    my @c0 = @$r0;	            # 配列に戻す
    my @c1 = @$r1;
    my @all;                        # 全単語

    print "クラス0の単語全て：";
    print "@c0\n";
    print "クラス1の単語全て：";
    print "@c1\n";
    push(@all,@c0,@c1);

    foreach my $w0 (@c0){
        if(!defined($hash0{$w0})){
            $hash0{$w0}=1;
        }else{
            $hash0{$w0}++;
        }
    }
    foreach my $w1 (@c1){
        if(!defined($hash1{$w1})){
            $hash1{$w1}=1;
        }else{
            $hash1{$w1}++;
        }
    }
    foreach my $w (@all){
        if(!defined($All_word{$w})){
            $All_word{$w}=null;
        }
    }
    my @all_word = sort keys(%All_word);
    my $all_word = @all_word;   # 全単語数

    print "全ての単語一覧 = ","@all_word\n";

    print "＊条件付き確率P(t|0)=\n";
    my %total0 = ();
    $c0 = @c0;  # クラス0中に出現する単語数

    foreach my $w0 (@all_word){

        # 未定義の単語があれば計算がおかしくならないように0を値として取る
        if(!defined($hash0{$w0})){
            $hash0{$w0}=0;
        }
        # 条件確率P(t|c) を計算
        $total0{$w0} = ($hash0{$w0}+$delta)/($c0+$all_word);
        # w1 => 1
        $w0 =~ /[0-9]/;
        print "P($w0|0)=";
        # 計算結果を浮動小数点5桁で出力
        printf ('%.6f',$total0{$w0});
        print "\n";

    }

    print "＊条件確率log2P(t|0)=\n";
    foreach my $odds (@all_word){

        # 条件確率log2P(t|c) を計算
        $tmp = &log2($total0{$odds});
        printf('%s=%.6f',$odds,$tmp);
        print "\n";
    }

    print "＊条件付き確率P(t|1)=\n";
    my %total1 = ();
    $c1 = @c1;  # クラス1中に出現する単語数

    foreach my $w1 (@all_word){

        # 未定義の単語があれば計算がおかしくならないように0を値として取る
        if(!defined($hash1{$w1})){
            $hash1{$w1}=0;
        }
        # 条件確率P(t|c) を計算
        $total1{$w1} = ($hash1{$w1}+$delta)/($c1+$all_word);
        # w1 => 1
        $w1 =~ /[0-9]/;
        print "P($w1|1)=";
        # 計算結果を浮動小数点5桁で出力
        printf ('%.6f',$total1{$w1});
        print "\n";
    }
    print "条件確率log2P(t|1)=\n";
    foreach my $odds (@all_word){

        # 条件確率log2P(t|c) を計算
        $tmp = &log2($total1{$odds});
        printf('%s=%.6f',$odds,$tmp);
        print "\n";
    }
}
sub log2 {
    my $n = shift;
    return log($n)/log(2);
}
