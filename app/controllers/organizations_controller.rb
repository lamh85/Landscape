class OrganizationsController < ApplicationController

  # CREATE

  def new
    @organization = Organization.new
    1.times {@organization.markets.build}
  end

  def create
    @organization = Organization.new(organization_params)
    
    if @organization.save
      supplier_params[:supplier_ids][0..-2].each do |supplier|
        # Instantiate a supplier-client relationship
        @channel = Channel.new
        # Find the supplier in Org table
        @supplier = Organization.find(supplier)
        # The saved Org is the client
        @channel.client = @organization
        # The saved Org's supplier is @supplier
        @channel.organization = @supplier
        @channel.save
      end

      flash[:notice] = "Organization successfully created!"
      redirect_to @organization
    else
      render :new
    end

  end

  # READ

  def index
    @organizations = Organization.all.order('name ASC')
  end

  def show
    @organization = Organization.find(params[:id])
  end

  # UPDATE

  def edit
    @organization = Organization.find(params[:id])
    @inverse_competitors = @organization.inverse_competitors
    # byebug
  end


  def update
    @organization = Organization.find(params[:id])
    if @organization.update(organization_params)
      # Re-write the Channels
      Channel.destroy_all("client_id = #{@organization.id}")
      supplier_params[:supplier_ids][0..-2].each do |supplier|
        # Instantiate a supplier-client relationship
        @channel = Channel.new
        # Find the supplier in Org table
        @supplier = Organization.find(supplier)
        # The saved Org is the client
        @channel.client = @organization
        # The saved Org's supplier is @supplier
        @channel.organization = @supplier
        @channel.save
      end
      # Re-write Markets
      # Market.destroy_all("organization_id = #{organization.id}")

      redirect_to @organization
      flash[:notice] = "You have successfully updated this organization"
    else
      flash[:alert] = "Could not update this organization"
      render :edit
    end
  end

  # DESTROY

  # OTHER
  private

  def organization_params
    params.require(:organization).permit(:name, :city, :province, :country, :revenue, :description, :priority_id, 
      {competitor_ids: []}, {client_ids: []},
      {markets_attributes: [:id, :product, :category_id, :province, :country, :sales, :description, :_destroy] }
      )
  end

  def supplier_params 
    params.require(:organization).permit({supplier_ids: []})
  end

  # Parameters: {"utf8"=>"✓", "authenticity_token"=>"Zd0DwmwVSh5IJrGuFb01RFXOz8SmSPd4T666WcdX9QwZzXaNUr2ka7DNURdUPeA/icX/oqO8VIXixJdgMBmuHw==", "organization"=>{"name"=>"Best Company Ever", "street"=>"123 Fake Street", "city"=>"Vancouver", "province"=>"British Columbia", "country"=>"CA", "priority_id"=>"1", "revenue"=>"5678", "description"=>"some fake company", "markets_attributes"=>{"0"=>{"product"=>"iPod", "category_id"=>"1", "province"=>"British Columbia", "country"=>"CA", "sales"=>"400", "description"=>"", "_destroy"=>"false"}, "1"=>{"product"=>"", "category_id"=>"", "province"=>"", "country"=>"", "sales"=>"", "description"=>"", "_destroy"=>"false"}}, "competitor_ids"=>["4", ""], "supplier_ids"=>["5", ""], "client_ids"=>["6", ""]}, "commit"=>"Add Organization"}
end
