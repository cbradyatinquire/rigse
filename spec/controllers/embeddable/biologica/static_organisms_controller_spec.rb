require File.expand_path('../../../../spec_helper', __FILE__)

describe Embeddable::Biologica::StaticOrganismsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_biologica_static_organism
    assert_select('OTStaticOrganism') do
      assert_select('organism') do
        assert_select('OTOrganism') do
          assert_select('world') do
            assert_select('OTWorld')
          end
        end
      end
    end
  end

end

# <OTStaticOrganism local_id='static_organism_34'>
#   <organism>
#     <OTOrganism alleles='a:H,b:H' allowFatalCharacteristic='true' local_id='organism_762' name='Horned Male Dragon' sex='0' strain=''>
#       <world>
#         <OTWorld local_id='world_442' speciesPath='org/concord/biologica/worlds/dragon.xml'></OTWorld>
#       </world>
#     </OTOrganism>
#   </organism>
# </OTStaticOrganism>
