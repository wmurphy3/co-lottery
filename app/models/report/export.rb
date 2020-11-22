class Report::Export
  require 'csv' 

  def initialize(options={})
    
  end

  def get_csv
    @csv = CSV.generate(headers: true) do |csv|
      csv << ["Name","Phone","Email","Address","Entered At"]
      all_prizes.each do |k,v|
        puts ""
        csv << [k]
        v.each do |item|
          csv << [
            item.name,
            item.phone,
            item.email,
            item.address,
            item.entered_at
          ]
        end
      end
    end
  end

  private

  def all_prizes
    UserPrize.select('users.name, users.phone, users.email, users.address, user_prizes.created_at as entered_at, prizes.name as prize_name').joins(:prize, :user).all.to_a.group_by {|r| r['prize_name']}
  end
end