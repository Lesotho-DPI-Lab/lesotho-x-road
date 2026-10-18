<!--
   The MIT License

   Copyright (c) 2019- Nordic Institute for Interoperability Solutions (NIIS)
   Copyright (c) 2018 Estonian Information System Authority (RIA),
   Nordic Institute for Interoperability Solutions (NIIS), Population Register Centre (VRK)
   Copyright (c) 2015-2017 Estonian Information System Authority (RIA), Population Register Centre (VRK)

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
 -->
<template>
  <v-footer class="footer">
    <div class="flag-stripe" aria-hidden="true"><span /><span /><span /></div>
    <v-container class="pb-13">
      <v-row>
        <v-col cols="12" md="3" class="pt-4">
          <img :src="ministryLogoUrl" :alt="$t('branding.ministry')" class="ministry-logo" />
        </v-col>
        <v-col cols="12" sm="4" md="3" class="footer-col pt-5">
          <v-row>
            <v-col>
              <span class="footer-title">
                {{ $t('footer.software.title') }}
              </span>
            </v-col>
          </v-row>
          <v-row>
            <v-col class="py-0">
              {{ $t('footer.software.versionPrefix') }}&nbsp;
              <span data-test="app-footer-server-version">
                {{ appInfo }}
              </span>
            </v-col>
          </v-row>
          <v-row>
            <v-col class="footer-copyright">
              {{ $t('footer.copyright.text', { year: currentYear }) }}
            </v-col>
          </v-row>
        </v-col>
        <v-col cols="12" sm="4" md="3" class="footer-col pt-5">
          <v-row>
            <v-col>
              <span class="footer-title">
                {{ $t('footer.contact.title') }}
              </span>
            </v-col>
          </v-row>
          <v-row>
            <v-col class="py-0">
              <div>{{ $t('footer.contact.address') }}</div>
              <div>
                {{ $t('footer.contact.phoneLabel') }}:
                <a class="footer-link" :href="`tel:${$t('footer.contact.phone').replace(/\s/g, '')}`">{{ $t('footer.contact.phone') }}</a>
              </div>
              <div>
                {{ $t('footer.contact.emailLabel') }}:
                <a class="footer-link" :href="`mailto:${$t('footer.contact.email')}`">{{ $t('footer.contact.email') }}</a>
              </div>
              <div>{{ $t('footer.contact.hours') }}</div>
            </v-col>
          </v-row>
        </v-col>
        <v-col cols="12" sm="4" md="3" class="footer-col pt-5">
          <v-row>
            <v-col>
              <span class="footer-title">
                {{ $t('footer.support.title') }}
              </span>
            </v-col>
          </v-row>
          <v-row>
            <v-col class="py-0">
              <div>
                <a rel="noopener" class="footer-link" target="_blank" :href="$t('footer.support.portalUrl')">
                  {{ $t('footer.support.portal') }}
                </a>
              </div>
              <div>
                <a class="footer-link" :href="`mailto:${$t('footer.support.email')}`">
                  {{ $t('footer.support.reportIssue') }}
                </a>
              </div>
              <div>
                <a rel="noopener" class="footer-link" target="_blank" :href="$t('footer.support.docsUrl')">
                  {{ $t('footer.support.docs') }}
                </a>
              </div>
            </v-col>
          </v-row>
        </v-col>
      </v-row>
    </v-container>
  </v-footer>
</template>

<script lang="ts" setup>
import { ministryLogoUrl } from '../branding';
import { computed, inject } from 'vue';
import { key } from '../utils';

const currentYear = new Date().getFullYear();

const system = inject(key.system);

const appInfo = computed(() => system?.version());
</script>

<style lang="scss" scoped>
@use '../assets/colors';

$text-color: colors.$Black100;

.footer {
  background: colors.$WarmGrey10;
  padding: 0;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.footer-title {
  color: $text-color;
  font-size: 0.9rem;
  font-weight: bold;
}

.footer-col {
  color: $text-color;
  font-size: 0.875rem;
}

.footer-link {
  color: colors.$Purple100;
}

.footer-copyright {
  color: colors.$Black70;
  font-size: 0.8rem;
}

.ministry-logo {
  height: 64px;
  width: auto;
  max-width: 100%;
}

// Lesotho flag bands: blue, white, green
.flag-stripe {
  width: 100%;
  display: flex;
  flex-direction: column;

  span {
    height: 4px;
  }

  span:nth-child(1) {
    background: colors.$Purple100;
  }

  span:nth-child(2) {
    background: colors.$White100;
  }

  span:nth-child(3) {
    background: colors.$Success100;
  }
}
</style>
